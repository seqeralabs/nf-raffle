import base64

# String to encode
text = "https://docs.google.com/forms/d/e/1FAIpQLScYvVDqRnRS3LfQMmz2yvt2sfGUbRhBevserv-0-67CnzKqMA/viewform?usp=sf_link"

# Encode to base64
encoded = base64.b64encode(text.encode()).decode()

print(f"Base64 encoded string: {encoded}")
