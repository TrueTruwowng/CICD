<img width="1703" height="917" alt="image" src="https://github.com/user-attachments/assets/0e3b0da4-cc2c-4213-8dda-f17b8ae30323" />
<img width="1867" height="896" alt="image" src="https://github.com/user-attachments/assets/652b4f8a-807b-4453-b3b7-e2f81c590580" />

<<<<<<< HEAD
# CICD
=======
# Spring Boot + Auth0 OIDC SSO Demo

Ứng dụng mẫu tích hợp SSO với Auth0 sử dụng giao thức **OIDC** (không phải SAML) kết hợp:

- Spring Boot 3 (Java 21)
- Spring Security (OAuth2 Client + Resource Server JWT)
- Auth0 (OIDC Provider)
- Thymeleaf (MVC + View)
- REST API (public & private)
- JWT validation cho các endpoint `/api/**`

## 1. Chuẩn bị trên Auth0
1. Tạo tài khoản / đăng nhập Auth0.
2. Vào Dashboard > Applications > Create Application:
   - Name: `spring-oidc-demo`
   - Type: Regular Web Application.
3. Lấy `Domain`, `Client ID`, `Client Secret`.
4. Cấu hình Allowed Callback URLs:
   - `http://localhost:8080/login/oauth2/code/auth0`
5. Allowed Logout URLs:
   - `http://localhost:8080/`
6. Allowed Web Origins:
   - `http://localhost:8080`
7. (Tuỳ chọn) Nếu cần Access Token cho API riêng, tạo một API trong Auth0 (tab APIs) và lấy giá trị Identifier làm `AUTH0_AUDIENCE`.

## 2. Biến môi trường (khuyến nghị)
Thiết lập trong hệ thống hoặc IDE:
```
AUTH0_DOMAIN=your-tenant-region.auth0.com
AUTH0_CLIENT_ID=xxxxxxxxxxxxxxxx
AUTH0_CLIENT_SECRET=xxxxxxxxxxxxxxxx
AUTH0_AUDIENCE=https://your-api-identifier (nếu dùng)
```

Hoặc sửa trực tiếp trong `src/main/resources/application.yml` (không khuyến nghị commit secret thật).

## 3. Chạy ứng dụng
### Maven
```cmd
mvn spring-boot:run
```
Hoặc build jar:
```cmd
mvn clean package
java -jar target/untitled-1.0-SNAPSHOT.jar
```

Mở trình duyệt: http://localhost:8080

## 4. Các endpoint
| Endpoint | Mô tả | Bảo vệ |
|----------|-------|--------|
| `/` | Trang chủ | Công khai (hiển thị login nếu chưa auth) |
| `/profile` | Thông tin user (claims, id token) | Yêu cầu đăng nhập |
| `/api/public` | REST public | Công khai |
| `/api/private` | REST private trả JWT claims | Yêu cầu JWT / session |

## 5. Cơ chế bảo mật
- Đăng nhập qua OIDC Authorization Code Flow (`/oauth2/authorization/auth0`).
- Sau khi login, session chứa principal `OidcUser` để hiển thị claims ở Thymeleaf.
- Resource Server JWT: Nếu gọi `/api/private` bằng Bearer Token hợp lệ (issuer = Auth0 domain) thì trích xuất claims từ JWT.
- Nếu gọi qua trình duyệt sau login, Security sẽ dùng session (principal có thể không là Jwt) -> code xử lý cả hai trường hợp.

## 6. Tuỳ chỉnh Audience
Nếu muốn token có audience cho API (để dùng ở backend khác), đặt biến `AUTH0_AUDIENCE`. Code đã chèn tham số `audience` vào authorization request.

## 7. Ghi chú phát triển
- Tắt cache Thymeleaf (dev) trong `application.yml`.
- Có thể thêm role mapping từ claim `permissions` hay `roles` nếu cấu hình Rule/Action trong Auth0.

## 8. Mở rộng
- Thêm controller cho refresh token silent (SPA) hoặc PKCE cho public client.
- Thêm CustomGrantedAuthoritiesConverter để map quyền nâng cao.
- Viết integration test bằng `spring-security-test` với JWT giả.

## 9. Vấn đề thường gặp
| Lỗi | Nguyên nhân | Cách xử lý |
|-----|-------------|-----------|
| `invalid_redirect_uri` | Chưa khai báo URL callback | Thêm đúng URL trong Auth0 settings |
| 403 khi gọi `/api/private` với token | Audience/issuer sai | Kiểm tra domain & audience, token đúng API? |
| 401 khi chưa login | Hành vi bình thường | Đăng nhập qua link login |

## 10. License
MIT (tuỳ bạn chọn cập nhật).

>>>>>>> c035984 (initial commit)
