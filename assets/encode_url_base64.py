import base64

# String to encode
text = "https://docs.google.com/forms/u/0/d/e/1FAIpQLScYvVDqRnRS3LfQMmz2yvt2sfGUbRhBevserv-0-67CnzKqMA/formResponse"

# Encode to base64
encoded = base64.b64encode(bytes(text, 'utf-8'))

print(f"Base64 encoded string: {encoded}")
