<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer currentUserID = (Integer) session.getAttribute("userID");
    String partnerUsername = request.getParameter("partnerUsername");
    response.sendRedirect("chatRoom.jsp?partnerUsername=" + partnerUsername);
%>
