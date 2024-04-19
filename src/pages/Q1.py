import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt

from ..utils.get_results import highlight_top_wines_1, highlight_top_wines_2

# Configure the page
st.set_page_config(
    page_title="Wine Dashboard",
    page_icon="🏡",
)

#####Sidebar Start#####

# Add a sidebar
st.sidebar.markdown("### **Top10 Wines**")

# df1 = highlight_top_wines_1()
# df2 = highlight_top_wines_2()
# formatted_df1 = df1.style.format({
#     "measure": "{:.0f}".format,
#     "avg_rating": "{:.1f}".format,
#     "average_weighted_price": "{:.0f}".format,
# })
# st.table(formatted_df1)
# st.table(df2)

