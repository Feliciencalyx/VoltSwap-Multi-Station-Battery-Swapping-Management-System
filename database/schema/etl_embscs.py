"""
ETL Pipeline: Transform EMBSCS Raw Dataset into VoltSwap Relational Oracle Schema
Course: INSY 8311 - Database Development with PL/SQL
Student: NSHIMYUMUKIZA Felicien (ID: 20251SEN197)

Processes:
1. 34 Stations from VDF9 (compartments), VDF8 (distance), Table D.1 (vulnerability), VEF1 (disruptions), VEF2 (flood risk).
2. 3,128 Daily Observations unpivoted from PI_1, PI_2, PI_3 (Oct-Dec 2023).
3. VDF1 (SoC at swap) and VDF4 (swap completion time) mapped to daily metrics.
4. Generates clean SQL insert script: database/schema/02_insert_clean_data.sql.
"""

import os
import csv
import openpyxl

base_dir = os.path.join('data', 'raw', 'embscs-dataset-main')
sql_out_path = os.path.join('database', 'schema', '02_insert_clean_data.sql')

def run():
    print("Starting ETL on EMBSCS empirical dataset...")

    # 1. Parse VDF9 (Activated Compartments)
    wb_comp = openpyxl.load_workbook(os.path.join(base_dir, 'VDF9_Activated_compartment.xlsx'))
    comp = {}
    for r in wb_comp.active.iter_rows(values_only=True):
        if r[0] and str(r[0]).startswith('BS') and str(r[0]) != 'BSS':
            comp[str(r[0])] = int(r[1]) if r[1] is not None else 8

    # 2. Parse VDF8 (Distance to central hub in meters)
    wb_dist = openpyxl.load_workbook(os.path.join(base_dir, 'VDF8_Distance_between_stations.xlsx'))
    dist = {}
    for r in wb_dist.active.iter_rows(values_only=True):
        if r[0] and str(r[0]).startswith('BS') and str(r[0]) != 'BSS':
            dist[str(r[0])] = int(r[1]) if r[1] is not None else 2500

    # 3. Parse Table D.1 (Vulnerability scores)
    wb_vuln = openpyxl.load_workbook(os.path.join(base_dir, 'Table D.1. Vulnerability score of 34 locations in October, November, and December 2023.xlsx'))
    vuln = {}
    for r in wb_vuln.active.iter_rows(values_only=True):
        if len(r) > 4 and r[1] and str(r[1]).startswith('BS'):
            v_oct = round(float(r[2]), 3) if r[2] else 0.500
            v_nov = round(float(r[3]), 3) if r[3] else 0.500
            v_dec = round(float(r[4]), 3) if r[4] else 0.500
            vuln[str(r[1])] = (v_oct, v_nov, v_dec)

    # 4. Parse VDF1 (Avg SoC at Swap)
    wb_soc = openpyxl.load_workbook(os.path.join(base_dir, 'VDF1_SOC_Swapping.xlsx'))
    soc_avg = {}
    for r in wb_soc.active.iter_rows(values_only=True):
        if r[0] and str(r[0]).startswith('BS') and str(r[0]) != 'Station':
            vals = [float(v) for v in r[1:4] if v is not None and isinstance(v, (int, float))]
            soc_avg[str(r[0])] = round(sum(vals)/len(vals), 1) if vals else 14.5

    # 5. Parse VDF4 (Avg Swap Completion Time in minutes)
    wb_time = openpyxl.load_workbook(os.path.join(base_dir, 'VDF4_Swap_completion_time.xlsx'))
    swap_time = {}
    for r in wb_time.active.iter_rows(values_only=True):
        if r[0] and str(r[0]).startswith('BS') and str(r[0]) != 'Station':
            vals = [float(v) for v in r[1:4] if v is not None and isinstance(v, (int, float))]
            swap_time[str(r[0])] = round(sum(vals)/len(vals), 2) if vals else 1.35

    # 6. Parse VEF1 (Operational Disruptions)
    wb_disr = openpyxl.load_workbook(os.path.join(base_dir, 'VEF1_Operational_disruption.xlsx'))
    disruptions = {}
    for r in wb_disr.active.iter_rows(values_only=True):
        if r[0] and str(r[0]).startswith('BS') and str(r[0]) != 'Station':
            d_oct = int(r[1]) if r[1] is not None and isinstance(r[1], (int, float)) else 0
            d_nov = int(r[2]) if r[2] is not None and isinstance(r[2], (int, float)) else 0
            d_dec = int(r[3]) if r[3] is not None and isinstance(r[3], (int, float)) else 0
            disruptions[str(r[0])] = (d_oct, d_nov, d_dec)

    # Helper to read Performance Indicators (PI CSVs)
    def read_pi(prefix):
        res = {}
        for m in ['October', 'November', 'December']:
            fn = f'{prefix}_{m}.csv'
            path = os.path.join(base_dir, fn)
            with open(path, 'r', encoding='utf-8') as f:
                reader = csv.reader(f, delimiter=';')
                hdr = next(reader)
                stns = [s.strip() for s in hdr[1:] if s.strip()]
                for row in reader:
                    if not row or not row[0]: continue
                    dt = row[0].strip()
                    for idx, v in enumerate(row[1:len(stns)+1]):
                        st = stns[idx]
                        val = int(float(v)) if v.strip() else 0
                        res[(dt, st)] = val
        return res, stns

    pi1, all_stations = read_pi('PI_1_Throughput')
    pi2, _ = read_pi('PI_2_Unique_batteries')
    pi3, _ = read_pi('PI_3_Battery-swapping_customer')

    print(f"Loaded {len(all_stations)} stations and {len(pi1)} daily observation pairs.")

    # Assign stations to Kigali districts for VoltSwap localization
    districts = ['Nyarugenge', 'Gasabo', 'Kicukiro']

    with open(sql_out_path, 'w', encoding='utf-8') as out:
        out.write("""/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       database/schema/02_insert_clean_data.sql
  Description:  Populates 34 Stations, Station Disruptions, and 3,128 Daily
                Station Operations from the real-world EMBSCS dataset.
============================================================================
*/

SET FEEDBACK OFF;
SET DEFINE OFF;

PROMPT Inserting 34 Real-World STATIONS from EMBSCS Dataset...
""")

        for i, st in enumerate(all_stations):
            district = districts[i % 3]
            c_bays = comp.get(st, 8)
            d_meters = dist.get(st, 3500)
            v_score = vuln.get(st, (0.55, 0.55, 0.55))[0]
            st_name = f"VoltSwap Station {st}"
            out.write(f"INSERT INTO STATIONS (station_id, station_code, station_name, district, total_bays, distance_to_hub_m, vulnerability_score, station_status) VALUES ('{st}', '{st}', '{st_name}', '{district}', {c_bays}, {d_meters}, {v_score}, 'ACTIVE');\n")

        out.write("\nPROMPT Inserting STATION_DISRUPTIONS (VEF1 Outage Logs)...\n")
        disr_id = 1
        for st, (doct, dnov, ddec) in disruptions.items():
            if doct > 0:
                out.write(f"INSERT INTO STATION_DISRUPTIONS (disruption_id, station_id, month_recorded, outage_count, remarks) VALUES ({disr_id}, '{st}', '2023-10', {doct}, 'October operational disruption events logged');\n")
                disr_id += 1
            if dnov > 0:
                out.write(f"INSERT INTO STATION_DISRUPTIONS (disruption_id, station_id, month_recorded, outage_count, remarks) VALUES ({disr_id}, '{st}', '2023-11', {dnov}, 'November operational disruption events logged');\n")
                disr_id += 1
            if ddec > 0:
                out.write(f"INSERT INTO STATION_DISRUPTIONS (disruption_id, station_id, month_recorded, outage_count, remarks) VALUES ({disr_id}, '{st}', '2023-12', {ddec}, 'December operational disruption events logged');\n")
                disr_id += 1

        out.write(f"\nPROMPT Inserting Reference Data: BATTERY_MODELS...\n")
        out.write("INSERT INTO BATTERY_MODELS (model_id, model_name, capacity_kwh, nominal_voltage, rated_cycles) VALUES ('MOD_01', 'VoltCore-48V', 3.2, '48V', 1500);\n")
        out.write("INSERT INTO BATTERY_MODELS (model_id, model_name, capacity_kwh, nominal_voltage, rated_cycles) VALUES ('MOD_02', 'VoltMax-60V', 4.5, '60V', 2000);\n")
        out.write("INSERT INTO BATTERY_MODELS (model_id, model_name, capacity_kwh, nominal_voltage, rated_cycles) VALUES ('MOD_03', 'VoltPro-72V', 5.8, '72V', 2200);\n")

        out.write(f"\nPROMPT Inserting {len(pi1)} STATION_DAILY_METRICS records (PI_1, PI_2, PI_3 unpivoted)...\n")
        metric_id = 1
        for (dt, st), throughput in pi1.items():
            u_bat = pi2.get((dt, st), int(throughput * 0.9))
            cust = pi3.get((dt, st), int(throughput * 0.85))
            avg_soc = soc_avg.get(st, 14.5)
            s_time = swap_time.get(st, 1.35)
            out.write(f"INSERT INTO STATION_DAILY_METRICS (metric_id, station_id, operation_date, swap_throughput, unique_batteries_swapped, customers_served, avg_swap_time_min, avg_soc_pct) VALUES ({metric_id}, '{st}', DATE '{dt}', {throughput}, {u_bat}, {cust}, {s_time}, {avg_soc});\n")
            metric_id += 1

        out.write("\nPROMPT Inserting Seed Customer, Battery Hardware and Transactional Records...\n")
        for c_idx in range(1, 41):
            c_id = f"CUST_{1000+c_idx}"
            c_name = f"Customer_{1000+c_idx}"
            c_phone = f"+250788{c_idx:06d}"
            c_plate = f"RA{chr(65 + (c_idx % 7))} {100+c_idx}K"
            out.write(f"INSERT INTO CUSTOMERS (customer_id, customer_name, customer_phone, vehicle_plate, registration_date, account_status) VALUES ('{c_id}', '{c_name}', '{c_phone}', '{c_plate}', DATE '2023-09-01', 'ACTIVE');\n")

        for b_idx in range(1, 101):
            b_id = f"BAT_{b_idx:04d}"
            b_serial = f"BAT-{b_idx:04d}"
            st_assign = all_stations[b_idx % len(all_stations)]
            mod = 'MOD_01' if b_idx <= 50 else ('MOD_02' if b_idx <= 80 else 'MOD_03')
            soc = 95 if b_idx % 3 != 0 else 15
            stat = 'CHARGED' if soc >= 90 else 'PENDING_INSPECTION'
            out.write(f"INSERT INTO BATTERIES (battery_id, serial_number, model_id, current_station_id, current_soc_pct, health_status, total_swaps) VALUES ('{b_id}', '{b_serial}', '{mod}', '{st_assign}', {soc}, '{stat}', 12);\n")

        out.write("\nCOMMIT;\nPROMPT Clean data insertion from EMBSCS dataset completed successfully.\n")

    print(f"Generated clean SQL load script: {sql_out_path}")

if __name__ == '__main__':
    run()
