<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%
    int itemId = Integer.parseInt(request.getParameter("itemId"));
    float bidAmount = Float.parseFloat(request.getParameter("bidAmount"));
    float autoBid = Float.parseFloat(request.getParameter("autoBid"));
    Integer userId = (Integer) session.getAttribute("userID"); 

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try (Connection conn = new ApplicationDB().getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT MAX(bidAmount) AS maxBid FROM Bids WHERE itemId = " + itemId)) {
            if(rs.next() && bidAmount > rs.getFloat("maxBid")) {
                PreparedStatement ps = conn.prepareStatement("INSERT INTO Bids (itemId, userId, bidAmount, autoBid) VALUES (?, ?, ?, ?)");
                ps.setInt(1, itemId);
                ps.setInt(2, userId);
                ps.setFloat(3, bidAmount);
                ps.setFloat(4, autoBid);
                ps.executeUpdate();
                response.sendRedirect("bidSuccess.jsp");
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
    <title>Place Bid</title>
</head>
<body>
    <h1>Place a Bid on an Item</h1>
    <form action="placeBid.jsp" method="post">
        Item ID: <input type="number" name="itemId" required><br>
        Your Bid: <input type="text" name="bidAmount" required><br>
        Your Maximum AutoBid: <input type="text" name="autoBid" required><br>
        <button type="submit">Place Bid</button>
    </form>
</body>
</html>
