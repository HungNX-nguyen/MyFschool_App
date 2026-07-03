# myfschoolse1913

A new Flutter project.

## Getting Started

MyFschool là ứng dụng sổ liên lạc điện tử được xây dựng bằng Flutter, hướng đến việc kết nối nhà trường, giáo viên, học sinh và phụ huynh trên một nền tảng thống nhất.

Dự án tập trung vào các nghiệp vụ chính của môi trường phổ thông như quản lý hồ sơ học sinh, lớp học, điểm số, thời khóa biểu, tình trạng nghỉ học, học phí, đơn từ, thông báo và câu lạc bộ. Hệ thống được định hướng phát triển theo mô hình client-server, trong đó Flutter đóng vai trò giao diện người dùng, backend REST API xử lý nghiệp vụ và database lưu trữ dữ liệu tập trung.

Các vai trò chính trong hệ thống gồm:

- **Parent:** theo dõi thông tin học tập, học phí, thời khóa biểu và hoạt động của con thông qua cơ chế Current Student.
- **Student:** đăng nhập để xem dữ liệu học tập, thời khóa biểu, lịch thi, bài tập và thông báo của chính mình.
- **Teacher:** nhập điểm, xử lý thông tin nghỉ học, duyệt đơn xin nghỉ, gửi thông báo và quản lý câu lạc bộ nếu được phân công.
- **Admin:** quản lý tài khoản, học sinh, lớp học, phân công giáo viên, học phí, câu lạc bộ và audit log.

Tài liệu phân tích nghiệp vụ và định hướng hệ thống nằm trong thư mục [docs](docs/), bao gồm tổng quan hệ thống, business flow và phân quyền theo vai trò.

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
