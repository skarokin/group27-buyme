<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%
/*
* ======= 
* THIS FILE IS TEMPORARY; THIS WILL BE USED TO IMPLEMENT BID AUTO-INCREMENT. THIS IS NOT TO BE USED UNTIL MODIFIED! 
* IF YOU MODIFY THIS FILE TO IMPLEMENT AUTOINCREMENT THEN U CAN DELETE THIS COMMENT
* ======
*/
    int bidId = Integer.parseInt(request.getParameter("bidId"));
    float bidAmount = Float.parseFloat(request.getParameter("bidAmount"));
    float autoBid = Float.parseFloat(request.getParameter("autoBid"));
    Integer userId = (Integer) session.getAttribute("userID"); 

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try (Connection conn = new ApplicationDB().getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT bidAmount FROM Bids WHERE bidID = " + bidId)) {
            if(rs.next() && bidAmount > rs.getFloat("bidAmount")) {
                PreparedStatement ps = conn.prepareStatement("UPDATE Bids SET bidAmount = ?, autoBid = ? WHERE bidID = ?");
                ps.setFloat(1, bidAmount);
                ps.setFloat(2, autoBid);
                ps.setInt(3, bidId);
                ps.executeUpdate();
                response.sendRedirect("bidSuccess.jsp");
            } else {
                // Handle the case where the new bid is not higher than the current bid
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Update Bid</title>
</head>
<body>
    <h1>Update Your Bid</h1>
    <form action="updateBid.jsp" method="post">
        Bid ID: <input type="number" name="bidId" required><br>
        Your New Bid: <input type="text" name="bidAmount" required><br>
        Your New Maximum AutoBid: <input type="text" name="autoBid" required><br>
        <button type="submit">Update Bid</button>
    </form>
</body>
</html>