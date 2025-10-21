


class ValidateFields {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name required";
    } else if (value.length < 2) {
      return "Enter at least 2 characters";
    } else if(value.length > 20){
      return "Name cannot exceed 20 characters";
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Last name is required";
    } else if (value.length < 2) {
      return "Enter at least 2 characters";
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    } else if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
      return "Enter a valid phone number";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    } else if (value.length < 8) {
      return "Password must be 8 characters";
    } else if(value.length > 25){
      return "Password exceed the limit";
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return "Confirm your password";
    } else if (value != original) {
      return "Passwords do not match";
    }
    return null;
  }


  static String? validateBio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Bio is required";
    } else if (value.length < 10) {
      return "Bio must be at least 10 characters";
    } else if (value.length > 70) {
      return "Bio cannot exceed 70 characters";
    }
    return null;
  }

  static String? validateProfessionalStatus(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Professional status is required";
    } else if (value.length < 2) {
      return "Enter a valid professional status";
    }
    return null;
  }
}
