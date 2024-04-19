import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt

from ..utils.get_results import prioritize_country
    

# Configure the page
st.set_page_config(
    page_title="Wine Dashboard",
    page_icon="🏡",
)

## DUMMY DATA - To be removed!!
marketing_priorities = pd.DataFrame({
    "Country": ["Italy", "Spain", "France", "USA", "Australia"],
    "Average Rating": [4.2, 4.0, 4.5, 4.1, 4.3],
    "Number of Wineries": [150, 120, 130, 160, 110],
    "Average Price": [30, 25, 45, 35, 28],
    "Marketing Score": [88, 85, 90, 87, 86]
})

#####Sidebar Start#####
# Add a sidebar
st.sidebar.markdown("### **Marketing Priorities**")
st.header("Marketing Budget Prioritization")
st.table(marketing_priorities)
fig, ax = plt.subplots()
ax.scatter(marketing_priorities["Country"], marketing_priorities["Marketing Score"], color='green')
plt.xlabel("Country")
plt.ylabel("Marketing Score")
st.pyplot(fig)