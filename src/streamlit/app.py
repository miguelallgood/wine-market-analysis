import streamlit as st
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Dummy Data Preparation
# You can replace these with actual database queries or more complex data structures as needed.
top_10_wines = pd.DataFrame({
    "Wine Name": ["Chateau Margaux", "Silver Oak Cabernet", "Caymus Cabernet", "Chardonnay Premiere", "Merlot Magic"],
    "Ratings Average": [4.5, 4.3, 4.6, 4.2, 4.1],
    "Price": [350, 220, 185, 90, 75],
    "Country": ["France", "USA", "USA", "USA", "France"],
    "Selection Reason": ["High rating & popularity", "Best seller in USA", "Excellent reviews", "Top choice for events", "Affordable luxury"]
})

marketing_priorities = pd.DataFrame({
    "Country": ["Italy", "Spain", "France", "USA", "Australia"],
    "Average Rating": [4.2, 4.0, 4.5, 4.1, 4.3],
    "Number of Wineries": [150, 120, 130, 160, 110],
    "Average Price": [30, 25, 45, 35, 28],
    "Marketing Score": [88, 85, 90, 87, 86]
})

winery_awards = pd.DataFrame({
    "Winery": ["Domaine de la Romanée-Conti", "Penfolds", "Screaming Eagle"],
    "Location": ["France", "Australia", "USA"],
    "Average Rating": [4.9, 4.7, 4.8],
    "Award Category": ["Lifetime Excellence", "Innovative Practices", "Consistent Quality"]
})

keyword_wines = pd.DataFrame({
    "Wine Name": ["Morning Fog Chardonnay", "Dark Horse Cabernet"],
    "Matched Keywords": [["cream", "citrus"], ["coffee", "toast"]],
    "User Confirmations": [12, 15],
    "Country": ["USA", "USA"]
})

common_grapes = pd.DataFrame({
    "Grape": ["Chardonnay", "Merlot"],
    "Wine Name": ["Sonoma Reserve", "Velvet Devil"],
    "Ratings Average": [4.1, 4.0],
    "Country": ["France", "USA"],
    "Availability Score": [95, 90]
})

country_ratings = pd.DataFrame({
    "Country": ["France", "Italy", "Spain"],
    "Average Rating": [4.5, 4.3, 4.1]
})

vintage_ratings = pd.DataFrame({
    "Year": [1990, 2000, 2010],
    "Average Rating": [4.2, 4.4, 4.6]
})

vip_recommendations = pd.DataFrame({
    "Wine Name": ["Opus One", "Screaming Eagle"],
    "Vintage Year": [2015, 2012],
    "Country": ["USA", "USA"],
    "Rating": [4.7, 4.9],
    "Tasting Note": ["Rich and robust with a velvety texture", "Elegant and intense, notes of blackberry and spice"]
})

# Streamlit App Layout
st.title('Wine Dashboard')

# Navigation
view = st.sidebar.selectbox("Choose a view", [
    "Top 10 Wines",
    "Marketing Priorities",
    "Winery Awards",
    "Keyword Wines",
    "Common Grapes",
    "Country & Vintage Ratings",
    "VIP Recommendations"
])

if view == "Top 10 Wines":
    st.header("Top 10 Wines to Increase Sales")
    st.table(top_10_wines)
    fig, ax = plt.subplots()
    ax.bar(top_10_wines["Wine Name"], top_10_wines["Ratings Average"], color='skyblue')
    plt.xticks(rotation=45, ha="right")
    plt.xlabel("Wine Name")
    plt.ylabel("Ratings Average")
    st.pyplot(fig)

elif view == "Marketing Priorities":
    st.header("Marketing Budget Prioritization")
    st.table(marketing_priorities)
    fig, ax = plt.subplots()
    ax.scatter(marketing_priorities["Country"], marketing_priorities["Marketing Score"], color='green')
    plt.xlabel("Country")
    plt.ylabel("Marketing Score")
    st.pyplot(fig)

elif view == "Winery Awards":
    st.header("Awards for Best Wineries")
    st.table(winery_awards)

elif view == "Keyword Wines":
    st.header("Keyword-Related Wine Selection")
    st.table(keyword_wines)

elif view == "Common Grapes":
    st.header("Global Wine Accessibility")
    st.table(common_grapes)

elif view == "Country & Vintage Ratings":
    st.header("Country and Vintage Leaderboard")
    st.write("Country Ratings")
    st.table(country_ratings)
    st.write("Vintage Ratings")
    st.table(vintage_ratings)

elif view == "VIP Recommendations":
    st.header("Top Picks for a VIP Client")
    st.table(vip_recommendations)
    fig, ax = plt.subplots()
    ax.plot(vip_recommendations["Wine Name"], vip_recommendations["Rating"], marker='o', linestyle='-')
    plt.xticks(rotation=45, ha="right")
    plt.xlabel("Wine Name")
    plt.ylabel("Rating")
    st.pyplot(fig)
