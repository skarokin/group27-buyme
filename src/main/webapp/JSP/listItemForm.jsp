<!DOCTYPE html>
<html>
<head>
    <title>List an Item</title>
</head>
<body>
    <h1>List a New Item for Sale</h1>
    <form action="<%=request.getContextPath()%>/JSP/listItem.jsp" method="post">
        Make: <input type="text" name="make" required><br>
        Model: <input type="text" name="model" required><br>
        Year: <input type="number" name="year" required><br>
        Color: <input type="text" name="color" required><br>
        Description: <textarea name="description" required></textarea><br>
        Close Time: <input type="datetime-local" name="closeTime" required><br>
        Initial Price: <input type="number" name="initialPrice" required><br>
        Minimum Selling Price: <input type="number" name="minSellPrice" required><br>
        Minimum Bid Increment: <input type="number" name="minBidIncrement" required><br>
        Category:
        <select name="category" required>
            <option value="SUV">SUV</option>
            <option value="Car">Car</option>
            <option value="Truck">Truck</option>
        </select><br>
        <button type="submit">List Item</button>
    </form>
    <a href="<%=request.getContextPath()%>/JSP/dashboard.jsp">Back to Dashboard</a>
</body>
</html>
