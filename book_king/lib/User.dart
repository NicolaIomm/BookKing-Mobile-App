class BookKingUser{
  bool isLogged = false;
  String name;
  String email;
  String photoUrl;
  String phone;
  String token;

  void toggleLogin(){
    isLogged = !isLogged;
  }

  void setName(String name){
    this.name = name;
  }

  String getName() {
    return name;
  }

  void setEmail(String email){
    this.email = email;
  }

  String getEmail() {
    return email;
  }

  void setPhotoUrl(String photoUrl){
    this.photoUrl = photoUrl;
  }

  String getPhotoUrl() {
    return photoUrl;
  }

  void setPhone(String phone){
    this.phone = phone;
  }

  String getPhone() {
    return phone;
  }

  void setToken(String token){
    this.token = token;
  }

  String getToken(){
    return token;
  }

}
