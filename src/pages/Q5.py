import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt

from ..utils.get_results import select_common_grapes_wines
    

# Configure the page
st.set_page_config(
    page_title="Wine Dashboard",
    page_icon="🏡",
)

#####Sidebar Start#####

# Add a sidebar
st.sidebar.markdown("### **Top Rated Accessible Wines**")
st.header("Top Rated Wines from Worldwide Grapes")
st.table(select_common_grapes_wines())