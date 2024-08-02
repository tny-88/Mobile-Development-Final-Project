import uuid
from flask import Flask, request, jsonify
from flask_cors import CORS
import firebase_admin
import bcrypt
from firebase_admin import credentials, firestore
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from datetime import datetime, timedelta

app = Flask(__name__)
CORS(app)

# JWT Configuration
app.config['JWT_SECRET_KEY'] = 'your_secret_key'  # Replace with a secure key
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(days=7)
jwt = JWTManager(app)

# Initialize Firebase Admin SDK
cred = credentials.Certificate(r'key.json')
firebase_admin.initialize_app(cred)

# Get Firestore client
db = firestore.client()

#Helper function to get user reference
def get_user_ref(email):
    return db.collection('users').document(email)

##### Users API Endpoints #####

# Create a user
@app.route('/create_user', methods=['POST'])
def create_user():
    data = request.get_json()
    userID = str(uuid.uuid4())
    fname = data['fname']
    lname = data['lname']
    email = data['email']
    password = data['passwordHash']
    gender = data['gender']
    phoneNumber = data['phoneNumber']
    dob = data['dob']

    # Hash the password
    password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

    # Create user data dictionary with timestamps
    user_data = {
        'userID': userID,
        'fname': fname,
        'lname': lname,
        'email': email,
        'passwordHash': password_hash,
        'gender': gender,
        'phoneNumber': phoneNumber,
        'dob': dob,
        'createdAt': datetime.now(),
        'updatedAt': datetime.now()
    }

    # Check if email is already in use
    user_ref = db.collection('users').document(email)
    user_data_check = user_ref.get()
    if user_data_check.exists:
        return jsonify({'message': 'User already exists!'}), 409
    else:
        # Add user data to Firestore
        user_ref.set(user_data)

        # Create JWT
        access_token = create_access_token(identity=email)
        return jsonify({'message': 'User created successfully!', 'access_token': access_token}), 200

# User login
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data['email']
    password = data['password']

    # Fetch user data from Firestore
    user_ref = db.collection('users').document(email)
    user_data_check = user_ref.get()
    if not user_data_check.exists:
        return jsonify({'message': 'Invalid credentials!'}), 401

    user_data = user_data_check.to_dict()
    password_hash = user_data['passwordHash']

    if bcrypt.checkpw(password.encode('utf-8'), password_hash.encode('utf-8')):
        # Create JWT
        access_token = create_access_token(identity=email)
        return jsonify({'access_token': access_token}), 200
    else:
        return jsonify({'message': 'Invalid credentials!'}), 401

# Get User Details
@app.route('/get_user_details', methods=['GET'])
@jwt_required()
def get_user_details():
    current_user_email = get_jwt_identity()
    user_ref = get_user_ref(current_user_email)
    user_data = user_ref.get().to_dict()
    if user_data:
        return jsonify(user_data), 200
    else:
        return jsonify({'message': 'User not found'}), 404
    
# Edit User Details
@app.route('/update_user_details', methods=['PUT'])
@jwt_required()
def update_user_details():
    data = request.get_json()
    current_user_email = get_jwt_identity()
    user_ref = get_user_ref(current_user_email)
    user_data = user_ref.get().to_dict()
    
    if not user_data:
        return jsonify({'message': 'User not found'}), 404

    update_data = {}

    if 'fname' in data:
        update_data['fname'] = data['fname']
    if 'lname' in data:
        update_data['lname'] = data['lname']
    if 'phoneNumber' in data:
        phone_number = data['phoneNumber']
        if not phone_number.isdigit() or len(phone_number) != 10:
            return jsonify({'message': 'Invalid phone number'}), 400
        update_data['phoneNumber'] = phone_number
    if 'dob' in data:
        update_data['dob'] = data['dob']
    if 'gender' in data:
        update_data['gender'] = data['gender']

    if update_data:
        update_data['updatedAt'] = datetime.now()
        user_ref.update(update_data)

    return jsonify({'message': 'User details updated successfully!'}), 200



@app.route('/add_medication', methods=['POST'])
@jwt_required()
def add_medication():
    user_email = get_jwt_identity()
    user_ref = db.collection('users').document(user_email)
    user_data = user_ref.get().to_dict()

    if not user_data:
        return jsonify({'message': 'User not found'}), 404

    data = request.get_json()
    medication_id = str(uuid.uuid4())
    medication_data = {
        'medicationID': medication_id,
        'name': data.get('name'),
        'dosage': data.get('dosage'),
        'schedule': data.get('schedule'),  # Store the datetime when the notification should appear
        'notes': data.get('notes', ''),
        'userID': user_data['userID'],
        'createdAt': datetime.now(),
        'updatedAt': datetime.now(),
    }

    db.collection('medications').document(medication_id).set(medication_data)

    return jsonify({'message': 'Medication added successfully!', 'medicationID': medication_id}), 200

@app.route('/update_medication/<medication_id>', methods=['PUT'])
@jwt_required()
def update_medication(medication_id):
    user_email = get_jwt_identity()
    user_ref = db.collection('users').document(user_email)
    user_data = user_ref.get().to_dict()

    if not user_data:
        return jsonify({'message': 'User not found'}), 404

    medication_ref = db.collection('medications').document(medication_id)
    medication_data = medication_ref.get().to_dict()

    if not medication_data:
        return jsonify({'message': 'Medication not found'}), 404

    data = request.get_json()
    updated_medication_data = {
        'name': data.get('name'),
        'dosage': data.get('dosage'),
        'schedule': data.get('schedule'),  # Store the datetime when the notification should appear
        'notes': data.get('notes', ''),
        'updatedAt': datetime.now(),
    }

    medication_ref.update(updated_medication_data)

    return jsonify({'message': 'Medication updated successfully!'}), 200

@app.route('/delete_medication/<medication_id>', methods=['DELETE'])
@jwt_required()
def delete_medication(medication_id):
    user_email = get_jwt_identity()
    user_ref = db.collection('users').document(user_email)
    user_data = user_ref.get().to_dict()

    if not user_data:
        return jsonify({'message': 'User not found'}), 404

    medication_ref = db.collection('medications').document(medication_id)
    medication_data = medication_ref.get().to_dict()

    if not medication_data:
        return jsonify({'message': 'Medication not found'}), 404

    medication_ref.delete()

    return jsonify({'message': 'Medication deleted successfully!'}), 200

@app.route('/get_medications', methods=['GET'])
@jwt_required()
def get_medications():
    user_email = get_jwt_identity()
    user_ref = db.collection('users').document(user_email)
    user_data = user_ref.get().to_dict()

    if not user_data:
        return jsonify({'message': 'User not found'}), 404

    medications_ref = db.collection('medications').where('userID', '==', user_data['userID'])
    medications = medications_ref.stream()
    medication_list = [medication.to_dict() for medication in medications]

    return jsonify(medication_list), 200

@app.route('/add_emergency_contact', methods=['POST'])
@jwt_required()
def add_emergency_contact():
    data = request.get_json()
    current_user_email = get_jwt_identity()
    user_ref = db.collection('users').document(current_user_email)
    user_data = user_ref.get().to_dict()

    if not user_data:
        return jsonify({'message': 'User not found'}), 404

    contact_data = {
        'fname': data.get('fname'),
        'lname': data.get('lname'),
        'phoneNumber': data.get('phoneNumber'),
        'relationship': data.get('relationship'),
        'userID': user_data['userID'],
        'createdAt': datetime.now(),
        'updatedAt': datetime.now(),
    }

    db.collection('emergency_contacts').add(contact_data)

    return jsonify({'message': 'Emergency contact added successfully!'}), 200
# Get Emergency Contacts
@app.route('/get_emergency_contacts', methods=['GET'])
@jwt_required()
def get_emergency_contacts():
    current_user_email = get_jwt_identity()
    user_ref = get_user_ref(current_user_email)
    user_data = user_ref.get().to_dict()
    user_id = user_data['userID']

    contacts_ref = db.collection('emergency_contacts').where('userID', '==', user_id)
    contacts = contacts_ref.stream()
    contacts_list = []
    for contact in contacts:
        contact_data = contact.to_dict()
        contact_data['contactID'] = contact.id
        contacts_list.append(contact_data)
    return jsonify(contacts_list), 200


# Update Emergency Contact
@app.route('/update_emergency_contact/<contact_id>', methods=['PUT'])
@jwt_required()
def update_emergency_contact(contact_id):
    data = request.get_json()
    contact_ref = db.collection('emergency_contacts').document(contact_id)
    contact_data_check = contact_ref.get()
    if not contact_data_check.exists:
        return jsonify({'message': 'Contact not found'}), 404

    contact_data = {
        'fname': data.get('fname'),
        'lname': data.get('lname'),
        'phoneNumber': data.get('phoneNumber'),
        'relationship': data.get('relationship'),
        'updatedAt': datetime.now(),
    }

    contact_ref.update(contact_data)

    return jsonify({'message': 'Contact updated successfully!'}), 200

# Delete Emergency Contact
@app.route('/delete_emergency_contact/<contact_id>', methods=['DELETE'])
@jwt_required()
def delete_emergency_contact(contact_id):
    contact_ref = db.collection('emergency_contacts').document(contact_id)
    contact_data_check = contact_ref.get()
    if not contact_data_check.exists:
        return jsonify({'message': 'Contact not found'}), 404

    contact_ref.delete()

    return jsonify({'message': 'Contact deleted successfully!'}), 200

# Protected route
@app.route('/protected', methods=['GET'])
@jwt_required()
def protected():
    current_user = get_jwt_identity()
    return jsonify({'message': f'Welcome, {current_user}'}), 200

# Error handling for expired tokens
@jwt.expired_token_loader
def expired_token_callback(jwt_header, jwt_payload):
    return jsonify({'message': 'Token has expired'}), 401

# Error handling for invalid tokens
@jwt.invalid_token_loader
def invalid_token_callback(error):
    return jsonify({'message': 'Invalid token'}), 401

if __name__ == '__main__':
    app.run(debug=True)
