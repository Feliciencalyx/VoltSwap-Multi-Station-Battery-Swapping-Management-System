"""
ETL Cleaning and SQL Script Generator for VoltSwap Database
Course: INSY 8311 - Database Development with PL/SQL
Student: NSHIMYUMUKIZA Felicien (ID: 20251SEN197)

Performs Phase IV Cleaning on raw data:
1. Deduplication (removes 14 duplicates).
2. Imputation of missing timestamps (16 records).
3. Imputation of missing inspection remarks (28 records).
4. District name canonicalization (Gasabo, Nyarugenge, Kicukiro).
5. Cleans and casts text fees ('RWF') and energy ('kWh') to numeric types.
6. Generates database/schema/02_insert_clean_data.sql.
"""

import csv
import re
import os

def run_etl():
    raw_path = os.path.join('data', 'raw', 'raw_battery_swaps.csv')
    sql_out_path = os.path.join('database', 'schema', '02_insert_clean_data.sql')

    with open(raw_path, 'r', encoding='utf-8') as f:
        reader = list(csv.DictReader(f))

    # Deduplicate based on swap_id
    seen_swaps = set()
    unique_rows = []
    for r in reader:
        s_id = r['swap_id']
        if s_id not in seen_swaps:
            seen_swaps.add(s_id)
            unique_rows.append(r)

    print(f"Loaded {len(reader)} raw rows. Deduplicated to {len(unique_rows)} unique transactions.")

    # Canonical stations and battery models
    station_map = {
        'Kigali Central Hub': ('STN_01', 'Kigali Central Hub', 'Nyarugenge', 24),
        'Remera Express': ('STN_02', 'Remera Express', 'Gasabo', 18),
        'Kimironko Station': ('STN_03', 'Kimironko Station', 'Gasabo', 16),
        'Kicukiro Center': ('STN_04', 'Kicukiro Center', 'Kicukiro', 20),
        'Gikondo Terminal': ('STN_05', 'Gikondo Terminal', 'Kicukiro', 15)
    }

    model_specs = {
        'VoltCore-48V': ('MOD_01', 'VoltCore-48V', 3.2, '48V', 1500),
        'VoltMax-60V': ('MOD_02', 'VoltMax-60V', 4.5, '60V', 2000),
        'VoltPro-72V': ('MOD_03', 'VoltPro-72V', 5.8, '72V', 2200)
    }

    customers = {}
    batteries = {}
    swaps = []
    payments = []
    inspections = []

    for idx, r in enumerate(unique_rows, 1):
        c_id = r['customer_id']
        if c_id not in customers:
            customers[c_id] = (c_id, r['customer_name'], r['customer_phone'], r['vehicle_plate'])

        st_name = r['station_name']
        st_id = station_map[st_name][0]

        mod_name = r['battery_model']
        mod_id = model_specs[mod_name][0]

        ret_bat = r['battery_returned_serial']
        ret_bat_id = ret_bat.replace('-', '_')
        if ret_bat_id not in batteries:
            batteries[ret_bat_id] = (ret_bat_id, ret_bat, mod_id, st_id, int(r['returned_soc_pct']), 'PENDING_INSPECTION')

        iss_bat = r['battery_issued_serial']
        iss_bat_id = iss_bat.replace('-', '_')
        if iss_bat_id not in batteries:
            batteries[iss_bat_id] = (iss_bat_id, iss_bat, mod_id, st_id, int(r['issued_soc_pct']), 'IN_USE')

        energy_clean = float(re.sub(r'[^\d.]', '', r['energy_consumed']))
        fee_clean = float(re.sub(r'[^\d.]', '', r['fee_amount']))

        swap_dt = r['swap_time'] if r['swap_time'] else f'2026-10-15 12:{(idx % 60):02d}:00'
        insp_notes = r['inspection_notes'] if r['inspection_notes'] else 'Standard inspection passed - no remarks recorded'
        insp_notes = insp_notes.replace("'", "''")

        swap_id = r['swap_id']
        swaps.append((swap_id, c_id, st_id, ret_bat_id, iss_bat_id, int(r['returned_soc_pct']), int(r['issued_soc_pct']), energy_clean, swap_dt, r['attendant_name']))

        num_id = swap_id.replace('SWP_', '')
        pay_id = f'PAY_{num_id}'
        payments.append((pay_id, swap_id, fee_clean, r['payment_method'], r['payment_status'], swap_dt))

        insp_id = f'INS_{num_id}'
        inspections.append((insp_id, ret_bat_id, r['attendant_name'], swap_dt, r['inspection_result'], insp_notes))

    # Write SQL script
    with open(sql_out_path, 'w', encoding='utf-8') as out:
        out.write("""/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       database/schema/02_insert_clean_data.sql
  Description:  Clean ETL data population script inserting normalized 3NF
                entities derived from raw_battery_swaps.csv.
============================================================================
*/

SET FEEDBACK OFF;
SET DEFINE OFF;

PROMPT Inserting Reference Data: STATIONS...
""")
        for s in station_map.values():
            out.write(f"INSERT INTO STATIONS (station_id, station_name, district, total_bays, station_status) VALUES ('{s[0]}', '{s[1]}', '{s[2]}', {s[3]}, 'ACTIVE');\n")

        out.write("\nPROMPT Inserting Reference Data: BATTERY_MODELS...\n")
        for m in model_specs.values():
            out.write(f"INSERT INTO BATTERY_MODELS (model_id, model_name, capacity_kwh, nominal_voltage, rated_cycles) VALUES ('{m[0]}', '{m[1]}', {m[2]}, '{m[3]}', {m[4]});\n")

        out.write(f"\nPROMPT Inserting {len(customers)} CUSTOMERS...\n")
        for c in customers.values():
            out.write(f"INSERT INTO CUSTOMERS (customer_id, customer_name, customer_phone, vehicle_plate, registration_date, account_status) VALUES ('{c[0]}', '{c[1]}', '{c[2]}', '{c[3]}', DATE '2026-01-10', 'ACTIVE');\n")

        out.write(f"\nPROMPT Inserting {len(batteries)} BATTERIES...\n")
        for b in batteries.values():
            out.write(f"INSERT INTO BATTERIES (battery_id, serial_number, model_id, current_station_id, current_soc_pct, health_status, total_swaps) VALUES ('{b[0]}', '{b[1]}', '{b[2]}', '{b[3]}', {b[4]}, '{b[5]}', 0);\n")

        out.write(f"\nPROMPT Inserting {len(swaps)} SWAP_TRANSACTIONS...\n")
        for sw in swaps:
            out.write(f"INSERT INTO SWAP_TRANSACTIONS (swap_id, customer_id, station_id, battery_in_id, battery_out_id, returned_soc_pct, issued_soc_pct, energy_consumed_kwh, swap_time, attendant_name) VALUES ('{sw[0]}', '{sw[1]}', '{sw[2]}', '{sw[3]}', '{sw[4]}', {sw[5]}, {sw[6]}, {sw[7]}, TO_TIMESTAMP('{sw[8]}', 'YYYY-MM-DD HH24:MI:SS'), '{sw[9]}');\n")

        out.write(f"\nPROMPT Inserting {len(payments)} PAYMENTS...\n")
        for p in payments:
            out.write(f"INSERT INTO PAYMENTS (payment_id, swap_id, amount_rwf, payment_method, payment_status, payment_time) VALUES ('{p[0]}', '{p[1]}', {p[2]}, '{p[3]}', '{p[4]}', TO_TIMESTAMP('{p[5]}', 'YYYY-MM-DD HH24:MI:SS');\n")

        out.write(f"\nPROMPT Inserting {len(inspections)} BATTERY_INSPECTIONS...\n")
        for ins in inspections:
            out.write(f"INSERT INTO BATTERY_INSPECTIONS (inspection_id, battery_id, inspector_name, inspection_date, physical_result, remarks) VALUES ('{ins[0]}', '{ins[1]}', '{ins[2]}', TO_TIMESTAMP('{ins[3]}', 'YYYY-MM-DD HH24:MI:SS'), '{ins[4]}', '{ins[5]}');\n")

        out.write("\nCOMMIT;\nPROMPT Clean data insertion completed successfully.\n")

    print(f"Generated clean SQL load script: {sql_out_path}")

if __name__ == '__main__':
    run_etl()
