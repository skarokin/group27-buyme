<%@ page import="java.sql.*, java.util.List, java.util.ArrayList, java.util.HashMap, java.util.Map" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%
    Integer loggedInUserId = (Integer) session.getAttribute("userID");
    String searchQuery = request.getParameter("searchQuery");
    List<Map<String, Object>> searchResults = new ArrayList<>();
    Map<Integer, Float> highestBids = new HashMap<>();
    Map<Integer, Float> initialPrices = new HashMap<>();

    if (searchQuery != null && !searchQuery.isEmpty()) {
        try (Connection conn = new ApplicationDB().getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                "SELECT i.*, (SELECT MAX(bidAmount) FROM bids WHERE itemID = i.itemID) AS highestBid " +
                "FROM Items i WHERE title LIKE ?"
            );
            stmt.setString(1, "%" + searchQuery + "%");
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("itemID", rs.getInt("itemID"));
                row.put("title", rs.getString("title"));
                row.put("ownerID", rs.getInt("userID"));
                row.put("initialPrice", rs.getFloat("initialPrice"));
                row.put("highestBid", rs.getFloat("highestBid") == 0 ? rs.getFloat("initialPrice") : rs.getFloat("highestBid"));
                searchResults.add(row);
                initialPrices.put(rs.getInt("itemID"), rs.getFloat("initialPrice"));
                highestBids.put(rs.getInt("itemID"), rs.getFloat("highestBid") == 0 ? rs.getFloat("initialPrice") : rs.getFloat("highestBid"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    String itemIDToBidStr = request.getParameter("itemIDToBid");
    String bidAmountStr = request.getParameter("bidAmount");
    if (itemIDToBidStr != null && bidAmountStr != null && !itemIDToBidStr.isEmpty() && !bidAmountStr.isEmpty() && loggedInUserId != null) {
        int itemIDToBid = Integer.parseInt(itemIDToBidStr);
        float bidAmount = Float.parseFloat(bidAmountStr);

        try (Connection conn = new ApplicationDB().getConnection()) {
            String checkBidQuery = "SELECT MAX(bidAmount) AS maxBid FROM bids WHERE itemID = ?";
            PreparedStatement checkBidStmt = conn.prepareStatement(checkBidQuery);
            checkBidStmt.setInt(1, itemIDToBid);
            ResultSet rs = checkBidStmt.executeQuery();
            
            float maxBid = 0;
            if (rs.next()) {
                maxBid = rs.getFloat("maxBid");
            }

            if (bidAmount > maxBid) {
                PreparedStatement insertBidStmt = conn.prepareStatement(
                    "INSERT INTO Bids (itemId, userId, bidAmount) VALUES (?, ?, ?)");
                insertBidStmt.setInt(1, itemIDToBid);
                insertBidStmt.setInt(2, loggedInUserId);
                insertBidStmt.setFloat(3, bidAmount);
                insertBidStmt.executeUpdate();
                response.sendRedirect("bidSuccess.jsp?itemIDToBid=" + itemIDToBid);
            } else {
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Search Items</title>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
            margin-top: 50px;
        }
        .form-input,
        .form-button,
        .link-button {
            margin: 10px;
            padding: 10px;
        }
        .form-input {
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .form-button {
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .form-button:hover {
            background-color: #0056b3;
        }
        .link-button {
            display: inline-block;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        .link-button:hover {
            background-color: #0056b3;
        }
        .bid-history,
        .overlay {
            display: none;
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background-color: white;
            border: 1px solid #000;
            padding: 20px;
            z-index: 2;
        }
        .overlay {
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
        }
        ul {
            list-style-type: none;
            padding: 0;
        }
        li {
            margin-bottom: 40px;
        }
    </style>
</head>
<body>
    <h1>Search for Items</h1>
    <form action="searchItems.jsp" method="post">
        Search Query: <input type="text" name="searchQuery" class="form-input" required><br>
        <button type="submit" class="form-button">Search</button>
    </form>

    <h2>Search Results:</h2>
    <% if (!searchResults.isEmpty()) { %>
<ul>
    <% for (Map<String, Object> item : searchResults) { %>
        <li>
            <%= item.get("title") %><br>
            Initial Price: $<%= item.get("initialPrice") %><br>
            Highest Bid: $<%= item.get("highestBid") %><br>
            <% if (!item.get("ownerID").equals(loggedInUserId)) { %>
                <form action="searchIt.jsp" method="post">
                    <input type="hidden" name="itemIDToBid" value="<%= item.get("itemID") %>">
                    Bid Amount: <input type="number" name="bidAmount" class="form-input" step="0.01" required><br>
                    Auto-Bid Limit: <input type="number" name="autoBidLimit" class="form-input" step="0.01" placeholder="Optional: Your max limit"><br>
                    <input type="submit" class="form-button" value="Place Bid / Set Auto-Bid">
                </form>
            <% } else { %>
                <form action="deleteItem.jsp" method="post">
                    <input type="hidden" name="itemID" value="<%= item.get("itemID") %>">
                    <input type="submit" class="form-button" value="Delete Listing" onclick="return confirm('Are you sure you want to delete this listing?');">
                </form>
            <% } %>
            <a href="viewBidHistory.jsp?itemID=<%=item.get("itemID")%>" class="link-button">View Bids</a>
        </li>
    <% } %>
</ul>
<% } else { %>
    <p>No results found.</p>
<% } %>
<a href="<%=request.getContextPath()%>/JSP/dashboard.jsp" class="link-button">Back to Dashboard</a>
</body>
</html>

