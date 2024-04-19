import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt

from ..utils.get_results import award_best_wineries
    

# Configure the page
st.set_page_config(
    page_title="Wine Dashboard",
    page_icon="🏡",
)

#####Sidebar Start#####

# Add a sidebar
st.sidebar.markdown("### **Winery Awards**")
st.header("Awards for Best Wineries")
st.table(award_best_wineries())
