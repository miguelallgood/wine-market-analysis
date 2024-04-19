import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt

from ..utils.get_results import find_wines_by_taste
    

# Configure the page
st.set_page_config(
    page_title="Wine Dashboard",
    page_icon="🏡",
)

## DUMMY Data - to remove!
keyword_wines = pd.DataFrame({
    "Wine Name": ["Morning Fog Chardonnay", "Dark Horse Cabernet"],
    "Matched Keywords": [["cream", "citrus"], ["coffee", "toast"]],
    "User Confirmations": [12, 15],
    "Country": ["USA", "USA"]
})

#####Sidebar Start#####

# Add a sidebar
st.sidebar.markdown("### **Keyword Wines**")
st.header("Keyword-Related Wine Selection")
st.table(keyword_wines)