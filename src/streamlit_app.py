import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt

from utils.get_results import award_best_wineries, recommend_cabernet_sauvignon, select_common_grapes_wines, \
    highlight_top_wines_1, highlight_top_wines_2, prioritize_country, find_wines_by_taste, create_country_vintage_visual_1, create_country_vintage_visual_2

header_style = '''
    <style>
        thead {
            
            background-color: rgb(255, 75, 75, 0.3);           
            
        }
    </style>

'''
st.markdown(header_style, unsafe_allow_html=True)

# Streamlit App Layout
st.title('Wine Dashboard')

# Navigation
view = st.sidebar.selectbox("Choose a view", [
    "Top 10 Wines",
    "Marketing Priorities",
    "Winery Awards",
    "Keyword Wines",
    "Top Rated Accessible Wines",
    "Country & Vintage Ratings",
    "VIP Recommendations"
])
# _____Question1_______
if view == "Top 10 Wines":
    st.header("Top 10 Wines to Increase Sales")
    st.write('Indicator is a measure that encapsulates: popularity, quality and vintage variety of a wine.')
    st.write('This approach is for new customers: it highlights wines that are popular and have a good revenue.')
    df1 = highlight_top_wines_1()      

    formatted_df1 = df1.rename(columns={
        "id": "Id",
        "name": "Wine", 
        "measure": "Indicator", 
        "total_count": "Number Reviews",
        "total_sale": "Estimated Revenue (€)",
        "avg_rating": "Avg Rating", 
        "average_weighted_price": "Avg Price (€)",
        "numb_vintages": "Number Vintages"
    })
    formatted_df1 = formatted_df1.style.format({
        "Indicator": "{:.0f}".format,
        "Avg Rating": "{:.1f}".format,
        "Avg Price (€)": "{:.0f}".format,
        "Estimated Revenue (€)": "{:.0f}".format
    })
    st.table(formatted_df1)

    df2 = highlight_top_wines_2()
    formatted_df2 = df2.rename(columns={
        "wine_id": "Id",
        "wine_name": "Wine", 
        "type_wine": "Type",
        "total_count": "Number Reviews",
        "total_sale": "Estimated Revenue (€)",
        "avg_rating": "Avg Rating", 
        "average_weighted_price": "Avg Price (€)",
        "numb_vintages": "Number Vintages"
    })
    formatted_df2 = formatted_df2.style.format({
        "Avg Rating": "{:.1f}".format,
        "Avg Price (€)": "{:.0f}".format,
        "Estimated Revenue (€)": "{:.0f}".format
    }) 
    st.write("But what about old customers?")
    st.write("Wine lovers don't stick to brands, but do like to stick to a type of wine.")
    st.write("The following table shows the top 10 wines inside the top 5 most popular wine types.")   
    st.table(formatted_df2)

# _____Question2_______
elif view == "Marketing Priorities":
    st.header("Marketing Budget Prioritization per Country")
    df = prioritize_country()
    formatted_df = df.rename(columns={
        "country": "Country",
        "count_wines": "Number of Wines", 
        "count_vintages": "Number of Vintages", 
        "sum_ratings_count": "Number Reviews",
        "sum_sales_euro": "Estimated Revenue (€)",
        "avg_price_bottle": "Avg Price (€)"
    })
    formatted_df = formatted_df.style.format({
        "Avg Price (€)": "{:.0f}".format,
        "Estimated Revenue (€)": "{:.0f}".format
    })
    st.table(formatted_df)
    """ France is popular and provides a lot of revenue, also it has a good availability of wines and vintages."""
    """At the same time, Italy also has a good availability of wines and vintages, but the price is cheap compared to France."""
    """Since France is already so popular, we recommend focusing on Italy to drive the median price up and improve revenue."""

# _____Question3_______
elif view == "Winery Awards":
    st.header("Awards for Best Wineries")
    df = award_best_wineries()
    formatted_df = df.rename(columns={
        "winery_name": "Winery",
        "num_of_wines": "Number of Wines", 
        "avg_rating": "Avg Rating", 
        "total_ratings": "Number Reviews",
        "avg_price": "Avg Price (€)"
    })
    formatted_df = formatted_df.style.format({
        "Avg Price (€)": "{:.0f}".format,
        "Avg Rating": "{:.1f}".format
    })
    st.table(formatted_df)

# _____Question4_______
elif view == "Keyword Wines":
    st.header("Keyword-Related Wine Selection")
    df = find_wines_by_taste()
    formatted_df = df.rename(columns={
        "wine_id": "Id",
        "wine": "Wine"
    })
    """Those are the wines that match all those flavors: 'coffee', 'toast', 'green apple', 'cream' and 'citrus'."""
    """As we can see, most are Brut Champagne. And therefore we would name this customer cluster as 'Lovers of Brut Champagne'"""

    st.table(formatted_df)


# _____Question5_______
elif view == "Top Rated Accessible Wines":
    st.header("Top Rated Wines from Worldwide Grapes")
    df = select_common_grapes_wines()
    formatted_df = df.rename(columns={
        "grape_name": "Grape",
        "wine_name": "Wine", 
        "rating": "Rating"
    })
    formatted_df = formatted_df.style.format({
        "Rating": "{:.0f}".format
    })
    st.table(formatted_df)

# _____Question6_______
elif view == "Country & Vintage Ratings":
    st.header("wines average rating per country")
    df = create_country_vintage_visual_1()
    formatted_df = df.rename(columns={
        "country_name": "Country",
        "avg_rating": "Average Rating"
    })
    formatted_df = formatted_df.style.format({
        "Average Rating": "{:.1f}".format
    })
    st.table(formatted_df)
    st.header("vintages average rating per country ")
    df = create_country_vintage_visual_2()
    formatted_df = df.rename(columns={
        "country_name": "Country",
        "year": "Vintage Year",
        "avg_rating": "Average Rating"
    })
    formatted_df = formatted_df.style.format({
        "Average Rating": "{:.1f}".format
    })
    st.table(formatted_df)


# _____Question7_______
elif view == "VIP Recommendations":
    st.header("Top Picks for a VIP Client")

    df = recommend_cabernet_sauvignon()
    formatted_df = df.rename(columns={
        "wine_name": "Wine", 
        "ratings_avg": "Average Rating",
        "ratings_count": "Number reviews"
    })
    formatted_df = formatted_df.style.format({
        "Average Rating": "{:.1f}".format
    })
    st.table(formatted_df)
    