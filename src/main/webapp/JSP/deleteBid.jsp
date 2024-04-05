<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>

<%
String bidIdParam = request.getParameter("bidID");
int bidId = 0;
if (bidIdParam != null && !bidIdParam.isEmpty()) {
    bidId = Integer.parseInt(bidIdParam);
}

Integer userId = (Integer) session.getAttribute("userID");

if (bidId > 0 && userId != null) {
    try (Connection conn = new ApplicationDB().getConnection()) {
        PreparedStatement ps = conn.prepareStatement("DELETE FROM Bids WHERE bidID = ? AND userID = ?");
        ps.setInt(1, bidId);
        ps.setInt(2, userId);
        int rowsAffected = ps.executeUpdate();
        if (rowsAffected > 0) {
            response.sendRedirect("deleteBidSuccess.jsp");
        } else {
            // Handle the case where the bid was not found or not owned by the user
            response.sendRedirect("error.jsp?message=Unable to delete bid");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("error.jsp?message=Error deleting bid");
    }
} else {
    response.sendRedirect("error.jsp?message=Invalid bid ID or user ID");
}
%>