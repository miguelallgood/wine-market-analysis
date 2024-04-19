import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt

from ..utils.get_results import recommend_cabernet_sauvignon
    

# Configure the page
st.set_page_config(
    page_title="Wine Dashboard",
    page_icon="🏡",
)

# DUMMY Data - to remove!
country_ratings = pd.DataFrame({
    "Country": ["France", "Italy", "Spain"],
    "Average Rating": [4.5, 4.3, 4.1]
})

vintage_ratings = pd.DataFrame({
    "Year": [1990, 2000, 2010],
    "Average Rating": [4.2, 4.4, 4.6]
})

#####Sidebar Start#####

# Add a sidebar
st.sidebar.markdown("### **VIP Recommendations**")
st.header("Top Picks for a VIP Client")
st.table(recommend_cabernet_sauvignon())