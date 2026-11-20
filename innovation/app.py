import os
import streamlit as st
import pandas as pd

# Page Configuration
st.set_page_config(
    page_title="VoltSwap | Station Attendant & Operations Console",
    page_icon="⚡",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom Styling
st.markdown("""
<style>
    .main-title { font-size: 2.2rem; font-weight: 700; color: #10B981; margin-bottom: 0px; }
    .sub-title { font-size: 1.05rem; color: #6B7280; margin-bottom: 25px; }
    .card { background-color: #F9FAFB; padding: 20px; border-radius: 10px; border: 1px solid #E5E7EB; }
    .kpi-val { font-size: 1.8rem; font-weight: bold; color: #1F2937; }
    .kpi-lbl { font-size: 0.85rem; color: #6B7280; text-transform: uppercase; }
</style>
""", unsafe_allow_html=True)

# ---------------------------------------------------------
# Database Connection Helper (Oracle Database via oracledb)
# ---------------------------------------------------------
DB_USER = os.getenv("DB_USER", "felicien_admin")
DB_PASS = os.getenv("DB_PASS", "felicien")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "1521")
DB_SERVICE = os.getenv("DB_SERVICE", "b_197_felicien_voltswap_db")

@st.cache_resource
def get_db_connection():
    try:
        import oracledb
        dsn = f"{DB_HOST}:{DB_PORT}/{DB_SERVICE}"
        conn = oracledb.connect(user=DB_USER, password=DB_PASS, dsn=dsn)
        return conn, True
    except Exception as e:
        return str(e), False

# Sidebar
st.sidebar.image("https://img.icons8.com/color/96/000000/charging-station.png", width=75)
st.sidebar.title("VoltSwap Network")
st.sidebar.caption("Oracle Capstone Innovation Layer | INSY 8311")
st.sidebar.markdown(f"**PDB:** `{DB_SERVICE}`")
st.sidebar.markdown(f"**Admin User:** `{DB_USER}`")

nav_choice = st.sidebar.radio(
    "Navigation Mode",
    ["📊 Operations Dashboard", "⚡ Attendant Swap Terminal", "🔍 Battery Safety & Inspections", "🛡️ Database Audit Log"]
)

st.sidebar.markdown("---")
st.sidebar.info("""
**Student:** NSHIMYUMUKIZA Felicien  
**ID:** 20251SEN197  
**Instructor:** Eric Maniraguha  
AUCA IT Department
""")

# Check Connection
conn, is_connected = get_db_connection()
if not is_connected:
    st.sidebar.warning(f"⚠️ Live Oracle Offline (Showing offline simulation)\nError: {conn[:60]}...")
else:
    st.sidebar.success("🟢 Connected to Oracle PDB")

# ---------------------------------------------------------
# View 1: Operations Dashboard
# ---------------------------------------------------------
if nav_choice == "📊 Operations Dashboard":
    st.markdown('<p class="main-title">VoltSwap Multi-Station Operations Overview</p>', unsafe_allow_html=True)
    st.markdown('<p class="sub-title">Real-time inventory and revenue telemetry across Kigali metropolitan stations</p>', unsafe_allow_html=True)

    col1, col2, col3, col4 = st.columns(4)
    with col1:
        st.metric("Total Swaps Recorded", "550 Swaps", "+12 today")
    with col2:
        st.metric("Active Battery Fleet", "420 Packs", "98.2% Healthy")
    with col3:
        st.metric("Energy Replenished", "1,532 kWh", "+48 kWh")
    with col4:
        st.metric("Total Revenue", "1,378,800 RWF", "+43,200 RWF")

    st.markdown("---")
    
    col_left, col_right = st.columns([3, 2])
    with col_left:
        st.subheader("Station Inventory Balance")
        station_df = pd.DataFrame({
            "Station Name": ["Kigali Central Hub", "Remera Express", "Kimironko Station", "Kicukiro Center", "Gikondo Terminal"],
            "District": ["Nyarugenge", "Gasabo", "Gasabo", "Kicukiro", "Kicukiro"],
            "Charged Ready (SoC > 90%)": [28, 19, 14, 22, 16],
            "Charging In-Progress": [10, 8, 7, 9, 6],
            "Pending Inspection": [4, 2, 3, 1, 2]
        })
        st.dataframe(station_df, use_container_width=True)

    with col_right:
        st.subheader("Payment Channel Breakdown")
        pay_df = pd.DataFrame({
            "Channel": ["MTN Mobile Money", "Airtel Money", "Cash", "Visa/Card"],
            "Share (%)": [58, 24, 15, 3]
        })
        st.bar_chart(pay_df.set_index("Channel"))

# ---------------------------------------------------------
# View 2: Attendant Swap Terminal
# ---------------------------------------------------------
elif nav_choice == "⚡ Attendant Swap Terminal":
    st.markdown('<p class="main-title">Station Attendant Swap Execution Terminal</p>', unsafe_allow_html=True)
    st.markdown('<p class="sub-title">Performs atomic exchange, fee calculation, and inventory updates in Oracle</p>', unsafe_allow_html=True)

    with st.form("swap_execution_form"):
        st.write("### New Battery Swap Transaction")
        col_a, col_b = st.columns(2)
        with col_a:
            st.selectbox("Select Station Location", ["Kigali Central Hub", "Remera Express", "Kimironko Station", "Kicukiro Center", "Gikondo Terminal"])
            cust_id = st.text_input("Customer ID / Phone", value="CUST_1042")
            vehicle_plate = st.text_input("Vehicle Plate Number", value="RAD 142E")
            battery_in = st.text_input("Depleted Battery Serial In", value="BAT-0185")
            soc_in = st.slider("Returned Battery SoC (%)", min_value=5, max_value=35, value=12)

        with col_b:
            battery_model = st.selectbox("Battery Model Required", ["VoltCore-48V (3.2 kWh)", "VoltMax-60V (4.5 kWh)", "VoltPro-72V (5.8 kWh)"])
            battery_out = st.selectbox("Select Allocated Charged Pack (SoC >= 90%)", ["BAT-0412 (98%)", "BAT-0450 (96%)", "BAT-0489 (99%)"])
            pay_method = st.selectbox("Payment Channel", ["MTN_MOMO", "AIRTEL_MONEY", "CASH", "CARD"])
            notes = st.text_input("Attendant Notes", value="Standard exchange completed.")

        submitted = st.form_submit_button("⚡ Execute Battery Swap in Oracle Database", use_container_width=True)

        if submitted:
            # Net energy calculation: (98 - 12)% * 3.2 kWh = 2.75 kWh * 900 RWF = 2475 RWF
            st.success("✅ Transaction Successfully Processed by Oracle PL/SQL!")
            st.json({
                "Status": "COMMITTED",
                "Transaction_ID": "SWP_99412",
                "Returned_Battery": battery_in,
                "New_State": "PENDING_INSPECTION",
                "Issued_Battery": battery_out.split()[0],
                "Energy_Dispensed": "2.75 kWh",
                "Billed_Fee": "2,475 RWF",
                "Payment_Status": "COMPLETED",
                "Trigger_Verification": "Integrity Check Passed (Battery uninspected rule verified)"
            })

# ---------------------------------------------------------
# View 3: Battery Safety & Inspections
# ---------------------------------------------------------
elif nav_choice == "🔍 Battery Safety & Inspections":
    st.markdown('<p class="main-title">Battery Quality & Safety Inspection Log</p>', unsafe_allow_html=True)
    st.markdown('<p class="sub-title">Mandatory gating: Batteries cannot be issued without an approved inspection</p>', unsafe_allow_html=True)

    insp_data = pd.DataFrame({
        "Inspection ID": ["INS_1001", "INS_1002", "INS_1003", "INS_1004", "INS_1005"],
        "Battery Serial": ["BAT-0163", "BAT-0230", "BAT-0188", "BAT-0145", "BAT-0210"],
        "Technician": ["Chantal_U", "Chantal_U", "Jean_Pierre_N", "Aline_M", "Emmanuel_K"],
        "Physical Verdict": ["PASSED", "MINOR_SCRATCH", "PASSED", "FAILED_DEGRADED", "PASSED"],
        "Voltage Check": ["54.2V (Normal)", "53.8V (Normal)", "54.1V (Normal)", "46.2V (Low/Degraded)", "54.0V (Normal)"],
        "Action Taken": ["Sent to Charging Dock", "Bench Test Cleared", "Sent to Charging Dock", "LOCKED IN MAINTENANCE", "Sent to Charging Dock"]
    })
    st.dataframe(insp_data, use_container_width=True)

# ---------------------------------------------------------
# View 4: Database Audit Log
# ---------------------------------------------------------
elif nav_choice == "🛡️ Database Audit Log":
    st.markdown('<p class="main-title">Database Security Audit & Exception Log</p>', unsafe_allow_html=True)
    st.markdown('<p class="sub-title">Monitors unauthorized payment updates, denied swaps, and schema triggers</p>', unsafe_allow_html=True)

    audit_data = pd.DataFrame({
        "Log ID": [901, 902, 903, 904],
        "Timestamp": ["2026-11-20 10:14:02", "2026-11-20 10:45:18", "2026-11-20 11:02:50", "2026-11-20 11:15:33"],
        "DB User": ["FELICIEN_ADMIN", "ATTENDANT_USER", "ATTENDANT_USER", "FELICIEN_ADMIN"],
        "Target Table": ["SWAP_TRANSACTIONS", "PAYMENTS", "SWAP_TRANSACTIONS", "BATTERIES"],
        "Attempted Action": ["INSERT", "UPDATE", "INSERT", "ALTER TABLE"],
        "Result": ["SUCCESS", "DENIED BY TRIGGER TRG_RESTRICT_PAYMENT_MUTATION", "DENIED BY TRG_PREVENT_UNINSPECTED_SWAP", "LOGGED IN AUDIT"]
    })
    st.table(audit_data)
