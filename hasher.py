from passlib.context import CryptContext


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

if __name__ == "__main__":
    # Example usage
    plain_password = "Kennwort1"
    print("Plain password:", plain_password)
    print("Hashed password:", hash_password(plain_password))