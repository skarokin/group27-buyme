<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>

<%
String itemIDStr = request.getParameter("itemID");
int itemID = itemIDStr != null ? Integer.parseInt(itemIDStr) : 0;

try (Connection conn = new ApplicationDB().getConnection()) {
    // Find the maximum bid for the current item
    String maxBidQuery = "SELECT MAX(bidAmount) as maxBid FROM Bids WHERE itemID = ?";
    PreparedStatement maxBidStmt = conn.prepareStatement(maxBidQuery);
    maxBidStmt.setInt(1, itemID);
    ResultSet rs = maxBidStmt.executeQuery();

    if (rs.next()) {
        float maxBid = rs.getFloat("maxBid");

        // Fetch the Item object from the database
        String itemQuery = "SELECT * FROM Items WHERE itemID = ?";
        PreparedStatement itemStmt = conn.prepareStatement(itemQuery);
        itemStmt.setInt(1, itemID);
        ResultSet itemResult = itemStmt.executeQuery();

        if (itemResult.next()) {
            float minBidIncrement = itemResult.getFloat("minBidIncrement"); // Assuming minBidIncrement is a column in your Items table

            // Update all bids for the current item where autoBid is present and increment them by minBidIncrement as long as it doesn't exceed autoBid
            String updateBidsQuery = "UPDATE Bids b JOIN Items i ON b.itemID = i.itemID SET b.bidAmount = LEAST(?, b.autoBid) WHERE b.itemID = ? AND b.bidAmount < b.autoBid";
            PreparedStatement updateBidsStmt = conn.prepareStatement(updateBidsQuery);
            updateBidsStmt.setFloat(1, maxBid + minBidIncrement);
            updateBidsStmt.setInt(2, itemID);
            updateBidsStmt.executeUpdate();
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
}
%>
