import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MusicPlayerApp());
}

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF222C36),
        fontFamily: 'Yekan Bakh FaNum',
      ),
      home: const NowPlayingScreen(),
    );
  }
}

/// مدل اطلاعات هر آهنگ روی کامپیوتر کاربر
class LocalTrack {
  final String filePath;
  final String title;
  final String artist;

  LocalTrack({
    required this.filePath,
    required this.title,
    required this.artist,
  });

  factory LocalTrack.fromFile(File file) {
    final baseName = p.basenameWithoutExtension(file.path);
    String artist = 'خواننده ناشناس';
    String title = baseName;

    if (baseName.contains(' - ')) {
      final parts = baseName.split(' - ');
      artist = parts.first.trim();
      title = parts.sublist(1).join(' - ').trim();
    } else {
      final parentName = p.basename(file.parent.path);
      if (parentName.isNotEmpty &&
          parentName.toLowerCase() != 'music' &&
          parentName.toLowerCase() != 'downloads' &&
          parentName.toLowerCase() != 'desktop') {
        artist = parentName;
      }
    }

    return LocalTrack(
      filePath: file.path,
      title: title,
      artist: artist,
    );
  }
}

/// مسیرهای دقیق SVG استخراج‌شده از طرح فیگما
class AppSvgPaths {
  static const String moreVert =
      'M0 9.75C0 10.9905 1.0095 12 2.25 12C3.4905 12 4.5 10.9905 4.5 9.75C4.5 8.5095 3.4905 7.5 2.25 7.5C1.0095 7.5 0 8.5095 0 9.75ZM0 17.25C0 18.4905 1.0095 19.5 2.25 19.5C3.4905 19.5 4.5 18.4905 4.5 17.25C4.5 16.0095 3.4905 15 2.25 15C1.0095 15 0 16.0095 0 17.25ZM0 2.25C0 3.4905 1.0095 4.5 2.25 4.5C3.4905 4.5 4.5 3.4905 4.5 2.25C4.5 1.0095 3.4905 0 2.25 0C1.0095 0 0 1.0095 0 2.25Z';

  static const String search =
      'M9.65925 19.3084C11.8044 19.3084 13.8882 18.5927 15.5806 17.2745L21.9653 23.6593C22.4423 24.12 23.2023 24.1067 23.663 23.6298C24.1123 23.1645 24.1123 22.4269 23.663 21.9617L17.2782 15.5769C20.5491 11.3664 19.7874 5.30149 15.5769 2.03058C11.3663 -1.24033 5.30149 -0.478645 2.03058 3.7319C-1.24033 7.94244 -0.478646 14.0073 3.7319 17.2782C5.42703 18.5951 7.51271 19.3095 9.65925 19.3084ZM4.52915 4.52545C7.36245 1.6921 11.9561 1.69204 14.7895 4.52535C17.6229 7.35866 17.6229 11.9524 14.7896 14.7857C11.9563 17.6191 7.36261 17.6191 4.52925 14.7858L4.52915 14.7857C1.69584 11.973 1.67915 7.3961 4.49181 4.56279L4.52915 4.52545Z';

  static const String arrowBack =
      'M12.8635 12.8565L2.0708 23.6456C1.59723 24.118 0.829956 24.118 0.355185 23.6456C-0.118392 23.1732 -0.118392 22.406 0.355185 21.9336L10.2918 12.0005L0.35638 2.06751C-0.117195 1.59513 -0.117195 0.827861 0.35638 0.354285C0.829957 -0.118095 1.59842 -0.118095 2.072 0.354285L12.8647 11.1433C13.331 11.6108 13.331 12.3901 12.8635 12.8565Z';

  static const String repeat =
      'M23.2042 11.2039H23.2041C22.7646 11.2039 22.4082 11.5603 22.4081 11.9998C22.4076 17.7388 17.7385 22.4079 11.9999 22.408H11.9987C8.34506 22.408 5.01558 20.5266 3.12722 17.4471H4.8352C5.2748 17.4471 5.63114 17.0908 5.63114 16.6512C5.63114 16.2116 5.2748 15.8552 4.8352 15.8552H1.00575C0.901222 15.8552 0.797718 15.8758 0.701147 15.9158C0.604577 15.9558 0.516831 16.0145 0.442921 16.0884C0.36901 16.1623 0.310383 16.25 0.270386 16.3466C0.230389 16.4432 0.209806 16.5467 0.209813 16.6512L0.209953 20.4806C0.209953 20.9202 0.566344 21.2765 1.00589 21.2765C1.44544 21.2765 1.80183 20.9201 1.80178 20.4806L1.80169 18.3291C2.77387 19.8924 4.09147 21.2121 5.65327 22.1868C6.58398 22.7679 7.59033 23.2181 8.64394 23.5245C9.72947 23.8399 10.8581 23.9999 11.9986 23.9999H12C13.6195 23.9999 15.1911 23.6825 16.671 23.0565C17.3846 22.7544 18.0673 22.3838 18.7095 21.95C19.3448 21.5208 19.9421 21.028 20.4849 20.4852C21.0277 19.9424 21.5205 19.345 21.9497 18.7098C22.3835 18.0675 22.7541 17.3848 23.0563 16.6711C23.6823 15.1913 23.9998 13.6197 24 12C24 11.5604 23.6437 11.204 23.2042 11.2039ZM0.796031 12.7958C1.23563 12.7957 1.59192 12.4394 1.59187 11.9998C1.59155 9.21956 2.67394 6.60591 4.63969 4.64016C6.60544 2.67441 9.21933 1.59183 11.9999 1.59183C15.5208 1.59183 18.7404 3.33881 20.6595 6.22148L18.5226 6.22181C18.083 6.22186 17.7267 6.5783 17.7268 7.01789C17.7269 7.45748 18.0832 7.81369 18.5227 7.81369H18.5228L22.5408 7.81308C22.9803 7.81303 23.3366 7.45669 23.3366 7.01714L23.3367 2.99977C23.3367 2.56017 22.9803 2.20383 22.5407 2.20383C22.1011 2.20383 21.7448 2.56017 21.7448 2.99977L21.7448 4.99575C20.8296 3.72426 19.6752 2.64347 18.3463 1.81392C17.4157 1.23264 16.4093 0.782369 15.3557 0.475828C14.2699 0.160078 13.1408 0 11.9999 0C10.38 0 8.80828 0.317344 7.3283 0.943266C6.61457 1.24539 5.93178 1.61595 5.28952 2.04975C4.65422 2.47894 4.05684 2.97178 3.51403 3.51459C2.97122 4.05741 2.47837 4.65473 2.04928 5.28998C1.61552 5.93223 1.24499 6.61498 0.942891 7.32867C0.317063 8.80861 -0.000187417 10.3803 8.30628e-08 12C4.69581e-05 12.4395 0.356438 12.7959 0.796031 12.7958Z';

  static const String heartFilled =
      'M12 20.7568C11.8786 20.7568 11.7572 20.7255 11.6485 20.6626C11.5304 20.5945 8.72392 18.965 5.8772 16.5098C4.18999 15.0547 2.84318 13.6114 1.87427 12.2201C0.620464 10.4199 -0.0100507 8.68822 0.000121129 7.07324C0.0120274 5.19402 0.685104 3.42674 1.89551 2.0969C3.12635 0.744655 4.76894 0 6.5208 0C8.76596 0 10.8187 1.25765 12.0001 3.24993C13.1814 1.2577 15.2341 0 17.4793 0C19.1344 0 20.7134 0.671905 21.9258 1.89196C23.2563 3.23085 24.0123 5.12263 23.9999 7.08214C23.9897 8.69431 23.3473 10.4233 22.0908 12.2211C21.1189 13.6117 19.7739 15.0543 18.0933 16.509C15.257 18.964 12.4707 20.5934 12.3535 20.6616C12.2461 20.724 12.1242 20.7568 12 20.7568Z';

  static const String heartOutline =
      'M12 21.3523C11.6583 21.3523 11.3289 21.2285 11.0722 21.0036C10.1026 20.1558 9.16789 19.3591 8.34317 18.6564L8.33895 18.6527C5.92105 16.5923 3.8331 14.8128 2.38035 13.06C0.75642 11.1004 0 9.24242 0 7.21269C0 5.24066 0.676217 3.42131 1.90392 2.08959C3.14629 0.742123 4.85099 0 6.70457 0C8.08995 0 9.35867 0.437999 10.4755 1.30172C11.039 1.73765 11.5499 2.27123 12 2.89359C12.4502 2.27123 12.9609 1.73765 13.5247 1.30172C14.6415 0.437999 15.9102 0 17.2956 0C19.149 0 20.8538 0.742123 22.0962 2.08959C23.3239 3.42131 24 5.24066 24 7.21269C24 9.24237 23.2437 11.1004 21.6198 13.0598C20.167 14.8128 18.0792 16.5921 15.6617 18.6524C14.8355 19.3562 13.8993 20.1542 12.9276 21.004C12.6708 21.2286 12.3412 21.3523 12 21.3523ZM6.70457 1.40587C5.24835 1.40587 3.91059 1.98707 2.93737 3.04246C1.94972 4.11384 1.40568 5.5948 1.40568 7.21269C1.40568 8.91978 2.04014 10.4465 3.4627 12.163C4.83763 13.8221 6.88274 15.5649 9.25067 17.5829L9.25503 17.5865C10.0828 18.292 11.0213 19.0918 11.998 19.9458C12.9805 19.0902 13.9204 18.2891 14.7498 17.5825C17.1176 15.5645 19.1625 13.8221 20.5374 12.163C21.9598 10.4465 22.5943 8.91978 22.5943 7.21269C22.5943 5.59475 22.0502 4.11379 21.0626 3.04246C20.0896 1.98707 18.7516 1.40587 17.2956 1.40587C16.2288 1.40587 15.2493 1.74501 14.3846 2.41368C13.6139 3.00988 13.077 3.76354 12.7622 4.29088C12.6004 4.56205 12.3155 4.72391 12 4.72391C11.6845 4.72391 11.3996 4.56205 11.2377 4.29088C10.9232 3.76354 10.3863 3.00988 9.61536 2.41368C8.75061 1.74501 7.77116 1.40587 6.70457 1.40587Z';

  static const String pause =
      'M10.5 4.5V37.5C10.5 38.6935 10.0259 39.8381 9.18198 40.682C8.33807 41.5259 7.19347 42 6 42H4.5C3.30653 42 2.16193 41.5259 1.31802 40.682C0.474106 39.8381 0 38.6935 0 37.5V4.5C0 3.30653 0.474106 2.16193 1.31802 1.31802C2.16193 0.474106 3.30653 0 4.5 0H6C7.19347 0 8.33807 0.474106 9.18198 1.31802C10.0259 2.16193 10.5 3.30653 10.5 4.5ZM25.5 0H24C22.8065 0 21.6619 0.474106 20.818 1.31802C19.9741 2.16193 19.5 3.30653 19.5 4.5V37.5C19.5 38.6935 19.9741 39.8381 20.818 40.682C21.6619 41.5259 22.8065 42 24 42H25.5C26.6935 42 27.8381 41.5259 28.682 40.682C29.5259 39.8381 30 38.6935 30 37.5V4.5C30 3.30653 29.5259 2.16193 28.682 1.31802C27.8381 0.474106 26.6935 0 25.5 0Z';

  static const String fastForwardPart =
      'M25.8747 17.0989L4.7901 0.352585C4.28635 0.100068 3.72668 -0.0202963 3.16366 0.00279319C2.60063 0.0258827 2.0527 0.191668 1.57132 0.484586C1.09244 0.770474 0.695917 1.17571 0.420502 1.66069C0.145088 2.14566 0.000201224 2.6938 0 3.25152L0 36.7543C0 37.8788 0.591464 38.9272 1.57132 39.5187C2.05384 39.8098 2.60199 39.9745 3.16506 39.9976C3.72812 40.0207 4.28791 39.9014 4.79264 39.6507L25.8772 22.8993C26.8926 21.9448 27.6947 21.229 27.6947 19.9978C27.6947 18.7667 27.0119 18.1041 25.8747 17.0989Z';

  static const String rewindPart =
      'M1.8201 17.0989L22.9047 0.352585C23.4084 0.100068 23.9681 -0.0202963 24.5311 0.00279319C25.0941 0.0258827 25.6421 0.191668 26.1234 0.484586C26.6023 0.770474 26.9988 1.17571 27.2743 1.66069C27.5497 2.14566 27.6946 2.6938 27.6948 3.25152V36.7543C27.6948 37.8788 27.1033 38.9272 26.1234 39.5187C25.6409 39.8098 25.0928 39.9745 24.5297 39.9976C23.9666 40.0207 23.4068 39.9014 22.9021 39.6507L1.81756 22.8993C0.80217 21.9448 1.33514e-05 21.229 1.33514e-05 19.9978C1.33514e-05 18.7667 0.682863 18.1041 1.8201 17.0989Z';

  static const String trackPlayLeft =
      'M1.32942 9.58228L17.5167 0.369445C19.2338 -0.610831 20.9844 0.461247 20.9844 2.38907V21.6218C20.9844 23.2551 19.9211 23.9998 18.9329 23.9998C18.4675 23.9998 17.9933 23.853 17.5223 23.5664L1.26237 13.6136C0.444939 13.1114 -0.0140667 12.3682 0.000301361 11.574C0.0138721 10.7789 0.497625 10.0525 1.32942 9.58228ZM2.35201 11.8358L18.6112 21.7862C18.6904 21.8367 18.776 21.8762 18.8658 21.9036C18.8884 21.8114 18.8991 21.7167 18.8978 21.6218V2.38987C18.8978 2.1919 18.8618 2.09211 18.8618 2.06737C18.798 2.07136 18.6862 2.10409 18.5457 2.18391L2.36079 11.3968C2.16122 11.5109 2.10215 11.6099 2.08299 11.5883C2.09337 11.6155 2.16122 11.7169 2.35201 11.8358Z';

  static const String addToPlaylist =
      'M20.362 11.665L14.87 8.526C14.6799 8.41738 14.4645 8.36063 14.2455 8.36141C14.0265 8.3622 13.8116 8.42049 13.6222 8.53047C13.4329 8.64044 13.2757 8.79823 13.1665 8.98804C13.0573 9.17785 12.9999 9.39302 13 9.612V15.888C12.9999 16.107 13.0573 16.3222 13.1665 16.512C13.2757 16.7018 13.4329 16.8596 13.6222 16.9695C13.8116 17.0795 14.0265 17.1378 14.2455 17.1386C14.4645 17.1394 14.6799 17.0826 14.87 16.974L20.362 13.835C20.554 13.7263 20.7136 13.5685 20.8247 13.3779C20.9358 13.1873 20.9944 12.9706 20.9944 12.75C20.9944 12.5294 20.9358 12.3127 20.8247 12.1221C20.7136 11.9315 20.554 11.7737 20.362 11.665ZM0.75 16.5H9.75C9.94891 16.5 10.1397 16.421 10.2803 16.2803C10.421 16.1397 10.5 15.9489 10.5 15.75C10.5 15.5511 10.421 15.3603 10.2803 15.2197C10.1397 15.079 9.94891 15 9.75 15H0.75C0.551088 15 0.360322 15.079 0.21967 15.2197C0.0790177 15.3603 0 15.5511 0 15.75C0 15.9489 0.0790177 16.1397 0.21967 16.2803C0.360322 16.421 0.551088 16.5 0.75 16.5ZM0.75 6.5H20.75C20.9489 6.5 21.1397 6.42098 21.2803 6.28033C21.421 6.13968 21.5 5.94891 21.5 5.75C21.5 5.55109 21.421 5.36032 21.2803 5.21967C21.1397 5.07902 20.9489 5 20.75 5H0.75C0.551088 5 0.360322 5.07902 0.21967 5.21967C0.0790177 5.36032 0 5.55109 0 5.75C0 5.94891 0.0790177 6.13968 0.21967 6.28033C0.360322 6.42098 0.551088 6.5 0.75 6.5ZM0.75 11.5H9.75C9.94891 11.5 10.1397 11.421 10.2803 11.2803C10.421 11.1397 10.5 10.9489 10.5 10.75C10.5 10.5511 10.421 10.3603 10.2803 10.2197C10.1397 10.079 9.94891 10 9.75 10H0.75C0.551088 10 0.360322 10.079 0.21967 10.2197C0.0790177 10.3603 0 10.5511 0 10.75C0 10.9489 0.0790177 11.1397 0.21967 11.2803C0.360322 11.421 0.551088 11.5 0.75 11.5ZM0.75 1.5H20.75C20.9489 1.5 21.1397 1.42098 21.2803 1.28033C21.421 1.13968 21.5 0.948912 21.5 0.75C21.5 0.551088 21.421 0.360322 21.2803 0.21967C21.1397 0.0790175 20.9489 0 20.75 0H0.75C0.551088 0 0.360322 0.0790175 0.21967 0.21967C0.0790177 0.360322 0 0.551088 0 0.75C0 0.948912 0.0790177 1.13968 0.21967 1.28033C0.360322 1.42098 0.551088 1.5 0.75 1.5Z';

  static const String share =
      'M16.9605 16.1435C15.8106 16.1435 14.7745 16.64 14.0555 17.43L7.58806 13.4244C7.76564 12.9705 7.85668 12.4874 7.85647 12C7.85668 11.5126 7.76564 11.0295 7.58806 10.5756L14.0555 6.5698C14.7746 7.35974 15.8106 7.85652 16.9605 7.85652C19.1266 7.85652 20.8888 6.0943 20.8888 3.92816C20.8888 1.76203 19.1266 0 16.9605 0C14.7944 0 13.0322 1.76222 13.0322 3.92835C13.0321 4.41571 13.1231 4.89879 13.3006 5.35269L6.83328 9.35834C6.11422 8.56841 5.07824 8.07162 3.92835 8.07162C1.76222 8.07162 0 9.83403 0 12C0 14.1661 1.76222 15.9283 3.92835 15.9283C5.07819 15.9283 6.11427 15.4317 6.83328 14.6416L13.3006 18.6473C13.1231 19.1012 13.0321 19.5844 13.0322 20.0718C13.0322 22.2377 14.7943 24 16.9605 24C19.1266 24 20.8888 22.2377 20.8888 20.0718C20.8888 17.9057 19.1266 16.1435 16.9605 16.1435ZM14.4646 3.92835C14.4646 2.5521 15.5843 1.43245 16.9605 1.43245C18.3367 1.43245 19.4564 2.5521 19.4564 3.92835C19.4564 5.3046 18.3367 6.42425 16.9605 6.42425C15.5842 6.42425 14.4646 5.30455 14.4646 3.92835ZM3.92835 14.4959C2.55192 14.4959 1.43226 13.3762 1.43226 12C1.43226 10.6238 2.55192 9.50408 3.92835 9.50408C5.3046 9.50408 6.42406 10.6238 6.42406 12C6.42406 13.3762 5.30455 14.4959 3.92835 14.4959ZM14.4646 20.0716C14.4646 18.6954 15.5843 17.5757 16.9605 17.5757C18.3367 17.5757 19.4564 18.6954 19.4564 20.0716C19.4564 21.4478 18.3367 22.5675 16.9605 22.5675C15.5842 22.5675 14.4646 21.4478 14.4646 20.0716';

  static const String settings =
      'M11.6293 8.31245C9.59279 8.31245 7.94181 9.96339 7.94181 12C7.94181 14.0365 9.59279 15.6874 11.6293 15.6874C13.6658 15.6874 15.3168 14.0365 15.3168 12C15.3168 9.96339 13.6658 8.31245 11.6293 8.31245ZM21.9794 9.36854L20.981 10.1904C19.8421 11.128 19.8421 12.8719 20.981 13.8094L21.9794 14.6313C22.3332 14.9226 22.4245 15.427 22.1954 15.8239L20.224 19.2385C19.9948 19.6354 19.5124 19.8084 19.0832 19.6476L17.8722 19.194C16.4908 18.6765 14.9806 19.5484 14.7381 21.0034L14.5255 22.2791C14.4501 22.7311 14.059 23.0624 13.6008 23.0624H9.65785C9.1996 23.0624 8.80848 22.7311 8.73315 22.2791L8.52053 21.0034C8.27804 19.5484 6.76778 18.6765 5.38643 19.194L4.17546 19.6476C3.74628 19.8084 3.26379 19.6354 3.03462 19.2385L1.06321 15.8239C0.834082 15.427 0.925441 14.9226 1.27925 14.6313L2.27769 13.8094C3.41651 12.8719 3.41651 11.128 2.27769 10.1904L1.27925 9.36854C0.925441 9.07726 0.834082 8.57289 1.06321 8.176L3.03462 4.7614C3.26379 4.36451 3.74628 4.19145 4.17546 4.35223L5.38643 4.80589C6.76778 5.32338 8.27804 4.45146 8.52053 2.99642L8.73315 1.72082C8.80848 1.2688 9.1996 0.937491 9.65785 0.937491H13.6008C14.059 0.937491 14.4501 1.2688 14.5255 1.72082L14.7381 2.99642C14.9806 4.45146 16.4908 5.32338 17.8722 4.80589L19.0832 4.35223C19.5124 4.19145 19.9948 4.36451 20.224 4.7614L22.1954 8.176C22.4245 8.57289 22.3332 9.07726 21.9794 9.36854Z';
}

/// ویجت رندر مستقیم مسیرهای SVG بدون نیاز به پکیج خارجی
class SvgPathIcon extends StatelessWidget {
  final String pathData;
  final Size viewBox;
  final double width;
  final double height;
  final Color color;
  final bool isStroke;
  final double strokeWidth;
  final PathFillType fillType;

  const SvgPathIcon({
    super.key,
    required this.pathData,
    required this.viewBox,
    required this.width,
    required this.height,
    this.color = Colors.white,
    this.isStroke = false,
    this.strokeWidth = 1.875,
    this.fillType = PathFillType.nonZero,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SvgPathPainter(
          pathData: pathData,
          viewBox: viewBox,
          color: color,
          isStroke: isStroke,
          strokeWidth: strokeWidth,
          fillType: fillType,
        ),
      ),
    );
  }
}

class _SvgPathPainter extends CustomPainter {
  final String pathData;
  final Size viewBox;
  final Color color;
  final bool isStroke;
  final double strokeWidth;
  final PathFillType fillType;

  _SvgPathPainter({
    required this.pathData,
    required this.viewBox,
    required this.color,
    required this.isStroke,
    required this.strokeWidth,
    required this.fillType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _parseSvgPath(pathData)..fillType = fillType;

    canvas.save();
    canvas.scale(size.width / viewBox.width, size.height / viewBox.height);

    final paint = Paint()
      ..color = color
      ..style = isStroke ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  Path _parseSvgPath(String d) {
    final path = Path();
    final regExp = RegExp(
      r'[MLHVCZ]|-?\d*\.?\d+(?:e[-+]?\d+)?',
      caseSensitive: false,
    );
    final tokens = regExp.allMatches(d).map((m) => m.group(0)!).toList();
    int i = 0;
    String cmd = '';
    double cx = 0, cy = 0;

    double nextNum() => double.parse(tokens[i++]);

    while (i < tokens.length) {
      final token = tokens[i];
      if (RegExp(r'^[MLHVCZ]$', caseSensitive: false).hasMatch(token)) {
        cmd = token.toUpperCase();
        i++;
      }
      switch (cmd) {
        case 'M':
          cx = nextNum();
          cy = nextNum();
          path.moveTo(cx, cy);
          cmd = 'L';
          break;
        case 'L':
          cx = nextNum();
          cy = nextNum();
          path.lineTo(cx, cy);
          break;
        case 'H':
          cx = nextNum();
          path.lineTo(cx, cy);
          break;
        case 'V':
          cy = nextNum();
          path.lineTo(cx, cy);
          break;
        case 'C':
          final x1 = nextNum(), y1 = nextNum();
          final x2 = nextNum(), y2 = nextNum();
          cx = nextNum();
          cy = nextNum();
          path.cubicTo(x1, y1, x2, y2, cx, cy);
          break;
        case 'Z':
          path.close();
          cmd = '';
          break;
        default:
          i++;
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _SvgPathPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.pathData != pathData;
  }
}

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<LocalTrack> _tracks = [];
  Set<String> _favoritePaths = {};
  List<String> _customPlaylistPaths = [];
  int _currentIndex = 0;
  bool _isScanning = false;

  bool isPlaying = false;
  bool isRepeat = false;
  bool isDragging = false;

  int totalSeconds = 296;
  double currentSeconds = 0;

  final String albumCoverUrl =
      'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop';

  static const Set<String> _supportedExtensions = {
    '.mp3',
    '.wav',
    '.m4a',
    '.aac',
    '.flac',
    '.ogg',
    '.wma',
  };

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _loadPreferencesAndScan();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _initAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((Duration d) {
      if (d.inSeconds > 0 && mounted) {
        setState(() {
          totalSeconds = d.inSeconds;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      if (!isDragging && mounted) {
        setState(() {
          currentSeconds =
              p.inMilliseconds / 1000.0;
        });
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      if (isRepeat) {
        _playTrackAt(_currentIndex);
      } else if (_tracks.isNotEmpty) {
        final nextIdx = (_currentIndex + 1) % _tracks.length;
        _playTrackAt(nextIdx);
      }
    });
  }

  Future<void> _loadPreferencesAndScan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoritePaths = (prefs.getStringList('favorites') ?? []).toSet();
      _customPlaylistPaths = prefs.getStringList('playlist') ?? [];
    });

    await _scanComputerForMusic();
  }

  /// اسکن خودکار پوشه‌های موزیک، دانلودها و دسکتاپ کامپیوتر کاربر
  Future<void> _scanComputerForMusic({String? extraDirectory}) async {
    if (_isScanning) return;
    setState(() => _isScanning = true);

    final List<LocalTrack> foundTracks = [];
    final Set<String> seenPaths = {};

    final List<String> dirsToScan = [];
    final userProfile = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'];

    if (userProfile != null && userProfile.isNotEmpty) {
      dirsToScan.addAll([
        p.join(userProfile, 'Music'),
        p.join(userProfile, 'Downloads'),
        p.join(userProfile, 'Desktop'),
      ]);
    }

    final prefs = await SharedPreferences.getInstance();
    final savedDirs = prefs.getStringList('custom_music_dirs') ?? [];
    for (final d in savedDirs) {
      if (!dirsToScan.contains(d)) dirsToScan.add(d);
    }

    if (extraDirectory != null && !dirsToScan.contains(extraDirectory)) {
      dirsToScan.add(extraDirectory);
      savedDirs.add(extraDirectory);
      await prefs.setStringList('custom_music_dirs', savedDirs);
    }

    for (final dirPath in dirsToScan) {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await _scanDirectorySafe(dir, foundTracks, seenPaths, maxDepth: 4);
      }
    }

    if (mounted) {
      setState(() {
        if (foundTracks.isNotEmpty) {
          _tracks = foundTracks;
          if (_currentIndex >= _tracks.length) {
            _currentIndex = 0;
          }
        }
        _isScanning = false;
      });
    }
  }

  Future<void> _scanDirectorySafe(
    Directory dir,
    List<LocalTrack> outTracks,
    Set<String> seenPaths, {
    int currentDepth = 0,
    int maxDepth = 4,
  }) async {
    if (currentDepth > maxDepth) return;
    try {
      await for (final entity
          in dir.list(recursive: false, followLinks: false)) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (_supportedExtensions.contains(ext) &&
              !seenPaths.contains(entity.path)) {
            seenPaths.add(entity.path);
            outTracks.add(LocalTrack.fromFile(entity));
          }
        } else if (entity is Directory) {
          final folderName = p.basename(entity.path);
          if (!folderName.startsWith('.') &&
              !folderName.startsWith(r'$') &&
              folderName.toLowerCase() != 'appdata' &&
              folderName.toLowerCase() != 'node_modules') {
            await _scanDirectorySafe(
              entity,
              outTracks,
              seenPaths,
              currentDepth: currentDepth + 1,
              maxDepth: maxDepth,
            );
          }
        }
      }
    } catch (_) {
      // نادیده گرفتن پوشه‌های سیستمی بدون دسترسی
    }
  }

  Future<void> _pickFolderAndScan() async {
    final String? selectedDirectory =
        await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'انتخاب پوشه آهنگ‌ها در کامپیوتر',
    );
    if (selectedDirectory != null) {
      await _scanComputerForMusic(extraDirectory: selectedDirectory);
      if (_tracks.isNotEmpty) {
        _playTrackAt(0);
      }
    }
  }

  Future<void> _pickAudioFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
      dialogTitle: 'انتخاب فایل‌های صوتی',
    );
    if (result != null && result.files.isNotEmpty) {
      int firstNewIndex = _tracks.length;
      setState(() {
        for (final f in result.files) {
          if (f.path != null) {
            final exists = _tracks.any((t) => t.filePath == f.path);
            if (!exists) {
              _tracks.add(LocalTrack.fromFile(File(f.path!)));
            }
          }
        }
      });
      if (_tracks.isNotEmpty) {
        _playTrackAt(
          firstNewIndex < _tracks.length ? firstNewIndex : _tracks.length - 1,
        );
      }
    }
  }

  Future<void> _playTrackAt(int index) async {
    if (_tracks.isEmpty || index < 0 || index >= _tracks.length) return;
    final track = _tracks[index];
    setState(() {
      _currentIndex = index;
      currentSeconds = 0;
    });
    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(track.filePath));
  }

  Future<void> _togglePlayPause() async {
    if (_tracks.isEmpty) {
      await _pickAudioFiles();
      return;
    }

    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_audioPlayer.state == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        await _playTrackAt(_currentIndex);
      }
    }
  }

  Future<void> _seekToSeconds(double seconds) async {
    final clamped = seconds.clamp(0.0, totalSeconds.toDouble());
    setState(() {
      currentSeconds = clamped;
    });
    if (_tracks.isNotEmpty) {
      await _audioPlayer.seek(Duration(milliseconds: (clamped * 1000).round()));
    }
  }

  LocalTrack get _currentTrack {
    if (_tracks.isEmpty) {
      return LocalTrack(
        filePath: '',
        title: 'آدمش نبودی',
        artist: 'فرزاد فرزین',
      );
    }
    return _tracks[_currentIndex];
  }

  LocalTrack get _nextTrack {
    if (_tracks.isEmpty) {
      return LocalTrack(
        filePath: '',
        title: 'آدمش نبودی',
        artist: 'فرزاد فرزین',
      );
    }
    final nextIdx = (_currentIndex + 1) % _tracks.length;
    return _tracks[nextIdx];
  }

  LocalTrack get _previousTrack {
    if (_tracks.isEmpty) {
      return LocalTrack(
        filePath: '',
        title: 'آدمش نبودی',
        artist: 'فرزاد فرزین',
      );
    }
    final prevIdx = (_currentIndex - 1 + _tracks.length) % _tracks.length;
    return _tracks[prevIdx];
  }

  bool get isCurrentFavorite {
    if (_tracks.isEmpty) return _favoritePaths.contains('default');
    return _favoritePaths.contains(_currentTrack.filePath);
  }

  Future<void> _toggleCurrentFavorite() async {
    final key = _tracks.isEmpty ? 'default' : _currentTrack.filePath;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoritePaths.contains(key)) {
        _favoritePaths.remove(key);
      } else {
        _favoritePaths.add(key);
      }
    });
    await prefs.setStringList('favorites', _favoritePaths.toList());
  }

  Future<void> _addCurrentToPlaylist() async {
    if (_tracks.isEmpty) return;
    final path = _currentTrack.filePath;
    final prefs = await SharedPreferences.getInstance();
    if (!_customPlaylistPaths.contains(path)) {
      _customPlaylistPaths.add(path);
      await prefs.setStringList('playlist', _customPlaylistPaths);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF060A12),
          content: Text(
            '«${_currentTrack.title}» به پلی‌لیست اضافه شد',
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  double get progress =>
      totalSeconds > 0 ? (currentSeconds / totalSeconds).clamp(0.0, 1.0) : 0.0;

  String _formatPersianTime(int seconds, {bool padMinutes = false}) {
    final int mins = seconds ~/ 60;
    final int secs = seconds % 60;
    final String minStr =
        padMinutes ? mins.toString().padLeft(2, '0') : mins.toString();
    final String secStr = secs.toString().padLeft(2, '0');
    return _toPersianDigits('$minStr:$secStr');
  }

  String _toPersianDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], persian[i]);
    }
    return input;
  }

  void _updateProgressFromTouch(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;

    double newProgress;
    if (dy < 0) {
      newProgress = dx < 0 ? 0.0 : 1.0;
    } else {
      final angle = math.atan2(dy, dx);
      newProgress = (1.0 - (angle / math.pi)).clamp(0.0, 1.0);
    }

    _seekToSeconds(newProgress * totalSeconds);
  }

  bool _isTouchNearArc(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final radius = size.width / 2;
    return dy >= -20 && (distance - radius).abs() <= 30;
  }

  /// پنجره لیست تمام آهنگ‌های پیدا شده روی کامپیوتر و جستجو
  void _openLibraryAndSearchSheet(
    BuildContext context, {
    bool onlyFavorites = false,
  }) {
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF060A12),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final sourceList = onlyFavorites
                ? _tracks
                    .where((t) => _favoritePaths.contains(t.filePath))
                    .toList()
                : _tracks;

            final filtered = sourceList.where((t) {
              if (searchQuery.isEmpty) return true;
              final q = searchQuery.toLowerCase();
              return t.title.toLowerCase().contains(q) ||
                  t.artist.toLowerCase().contains(q);
            }).toList();

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.72,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4B5767),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _pickFolderAndScan();
                                },
                                icon: const Icon(
                                  Icons.create_new_folder_outlined,
                                  color: Color(0xFF52BDE0),
                                  size: 18,
                                ),
                                label: const Text(
                                  'افزودن پوشه',
                                  style: TextStyle(
                                    color: Color(0xFF52BDE0),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _pickAudioFiles();
                                },
                                icon: const Icon(
                                  Icons.audio_file_outlined,
                                  color: Color(0xFFE02B7B),
                                  size: 18,
                                ),
                                label: const Text(
                                  'انتخاب فایل',
                                  style: TextStyle(
                                    color: Color(0xFFE02B7B),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            onlyFavorites
                                ? 'علاقه‌مندی‌ها (${_toPersianDigits(filtered.length.toString())})'
                                : 'آهنگ‌های کامپیوتر (${_toPersianDigits(filtered.length.toString())})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) =>
                            setModalState(() => searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'جستجوی نام آهنگ یا خواننده...',
                          hintTextDirection: TextDirection.rtl,
                          hintStyle: const TextStyle(
                            color: Color(0xFF8FA0A6),
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF222C36),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _isScanning
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFE02B7B),
                                ),
                              )
                            : filtered.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'آهنگی یافت نشد',
                                          style: TextStyle(
                                            color: Color(0xFF8FA0A6),
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFE02B7B),
                                          ),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await _pickFolderAndScan();
                                          },
                                          child: const Text(
                                            'انتخاب پوشه آهنگ از کامپیوتر',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: filtered.length,
                                    separatorBuilder: (_, __) => const Divider(
                                      color: Color(0xFF222C36),
                                      height: 1,
                                    ),
                                    itemBuilder: (context, idx) {
                                      final track = filtered[idx];
                                      final realIndex = _tracks.indexWhere(
                                        (t) => t.filePath == track.filePath,
                                      );
                                      final isCurrent =
                                          realIndex == _currentIndex;

                                      return ListTile(
                                        onTap: () {
                                          Navigator.pop(context);
                                          if (realIndex != -1) {
                                            _playTrackAt(realIndex);
                                          }
                                        },
                                        leading: Icon(
                                          isCurrent && isPlaying
                                              ? Icons.pause_circle_filled
                                              : Icons.play_circle_outline,
                                          color: isCurrent
                                              ? const Color(0xFFE02B7B)
                                              : Colors.white,
                                        ),
                                        title: Text(
                                          track.title,
                                          textAlign: TextAlign.right,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isCurrent
                                                ? const Color(0xFFE02B7B)
                                                : const Color(0xFF52BDE0),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        subtitle: Text(
                                          track.artist,
                                          textAlign: TextAlign.right,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF8FA0A6),
                                            fontSize: 11,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openBottomMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF060A12),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B5767),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _buildMenuItem(
                  title: 'افزودن به پلی لیست',
                  icon: const SvgPathIcon(
                    pathData: AppSvgPaths.addToPlaylist,
                    viewBox: Size(22, 18),
                    width: 22,
                    height: 18,
                    fillType: PathFillType.evenOdd,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _addCurrentToPlaylist();
                  },
                ),
                _buildMenuItem(
                  title: 'افزودن به علاقه مندی ها',
                  icon: const SvgPathIcon(
                    pathData: AppSvgPaths.heartOutline,
                    viewBox: Size(24, 22),
                    width: 24,
                    height: 21,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleCurrentFavorite();
                  },
                ),
                _buildMenuItem(
                  title: 'افزودن به پلی لیست',
                  icon: const SvgPathIcon(
                    pathData: AppSvgPaths.addToPlaylist,
                    viewBox: Size(22, 18),
                    width: 22,
                    height: 18,
                    fillType: PathFillType.evenOdd,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _openLibraryAndSearchSheet(context);
                  },
                ),
                _buildMenuItem(
                  title: 'اشتراک گذاری',
                  icon: const SvgPathIcon(
                    pathData: AppSvgPaths.share,
                    viewBox: Size(21, 24),
                    width: 21,
                    height: 24,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (_tracks.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF060A12),
                          content: Text(
                            'مسیر فایل: ${_currentTrack.filePath}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                ),
                _buildMenuItem(
                  title: 'تنظیمات',
                  icon: const SvgPathIcon(
                    pathData: AppSvgPaths.settings,
                    viewBox: Size(24, 24),
                    width: 24,
                    height: 24,
                    isStroke: true,
                    strokeWidth: 1.875,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFolderAndScan();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required String title,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 24,
              height: 24,
              child: Center(child: icon),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const arcSize = Size(298, 298);
    const activeRedColor = Color(0xFFE02B7B);

    final currentTrack = _currentTrack;
    final nextTrack = _nextTrack;
    final prevTrack = _previousTrack;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        // ۱. هدر بالا با آیکون‌های SVG خود طرح
                        SizedBox(
                          height: 28,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => _openBottomMenu(context),
                                        child: const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Center(
                                            child: SvgPathIcon(
                                              pathData: AppSvgPaths.moreVert,
                                              viewBox: Size(5, 20),
                                              width: 5,
                                              height: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () =>
                                            _openLibraryAndSearchSheet(context),
                                        child: const SvgPathIcon(
                                          pathData: AppSvgPaths.search,
                                          viewBox: Size(24, 24),
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () =>
                                        _openLibraryAndSearchSheet(context),
                                    child: const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Center(
                                        child: SvgPathIcon(
                                          pathData: AppSvgPaths.arrowBack,
                                          viewBox: Size(14, 24),
                                          width: 13,
                                          height: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                'در حال پخش',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ۲. بخش دیسک وینیل و نوار پیشرفت
                        SizedBox(
                          width: 352,
                          height: 298,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 24,
                                child: _buildVinylDisc(
                                  outerSize: 250,
                                  imageSize: 234,
                                  ringSize: 202,
                                  pinkSize: 32,
                                  holeSize: 16,
                                ),
                              ),

                              Positioned(
                                top: 0,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTapDown: (details) {
                                    if (_isTouchNearArc(
                                        details.localPosition, arcSize)) {
                                      _updateProgressFromTouch(
                                          details.localPosition, arcSize);
                                    }
                                  },
                                  onPanStart: (details) {
                                    if (_isTouchNearArc(
                                        details.localPosition, arcSize)) {
                                      isDragging = true;
                                      _updateProgressFromTouch(
                                          details.localPosition, arcSize);
                                    }
                                  },
                                  onPanUpdate: (details) {
                                    if (isDragging) {
                                      _updateProgressFromTouch(
                                          details.localPosition, arcSize);
                                    }
                                  },
                                  onPanEnd: (_) => isDragging = false,
                                  onPanCancel: () => isDragging = false,
                                  child: CustomPaint(
                                    size: arcSize,
                                    painter: ArcProgressPainter(
                                      progress: progress,
                                      trackColor: const Color(0xFF4B5767),
                                      progressColor: activeRedColor,
                                    ),
                                  ),
                                ),
                              ),

                              // زمان سپری شده سمت چپ
                              Positioned(
                                left: 0,
                                top: 119,
                                child: Text(
                                  _formatPersianTime(currentSeconds.round()),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                              // زمان کل سمت راست
                              Positioned(
                                right: 0,
                                top: 119,
                                child: Text(
                                  _formatPersianTime(
                                    totalSeconds,
                                    padMinutes: true,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                              // آیکون تکرار (در ابتدا غیرفعال/سفید، با کلیک قرمز)
                              Positioned(
                                left: 24,
                                bottom: 0,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      setState(() => isRepeat = !isRepeat),
                                  child: SvgPathIcon(
                                    pathData: AppSvgPaths.repeat,
                                    viewBox: const Size(24, 24),
                                    width: 24,
                                    height: 24,
                                    color: isRepeat
                                        ? activeRedColor
                                        : Colors.white,
                                  ),
                                ),
                              ),

                              // آیکون قلب (در ابتدا غیرفعال/سفید، با کلیک قرمز)
                              Positioned(
                                right: 18,
                                bottom: 0,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _toggleCurrentFavorite,
                                  child: SvgPathIcon(
                                    pathData: AppSvgPaths.heartFilled,
                                    viewBox: const Size(24, 21),
                                    width: 24,
                                    height: 21,
                                    color: isCurrentFavorite
                                        ? activeRedColor
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ۳. نام خواننده و نام آهنگ
                        Text(
                          currentTrack.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8FA0A6),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentTrack.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF52BDE0),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ۴. دکمه‌های کنترل پخش
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // دکمه عقب ( ۱۰ ثانیه به عقب یا آهنگ قبلی با نگه داشتن )
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _seekToSeconds(currentSeconds - 10),
                              onLongPress: () {
                                if (_tracks.isNotEmpty) {
                                  final prevIdx = (_currentIndex -
                                          1 +
                                          _tracks.length) %
                                      _tracks.length;
                                  _playTrackAt(prevIdx);
                                }
                              },
                              child: const SizedBox(
                                width: 48,
                                height: 48,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: 4,
                                      child: SvgPathIcon(
                                        pathData: AppSvgPaths.rewindPart,
                                        viewBox: Size(28, 40),
                                        width: 28,
                                        height: 40,
                                      ),
                                    ),
                                    Positioned(
                                      left: 20,
                                      top: 4,
                                      child: SvgPathIcon(
                                        pathData: AppSvgPaths.rewindPart,
                                        viewBox: Size(28, 40),
                                        width: 28,
                                        height: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // دکمه توقف / پخش
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _togglePlayPause,
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: Center(
                                  child: isPlaying
                                      ? const SvgPathIcon(
                                          pathData: AppSvgPaths.pause,
                                          viewBox: Size(30, 42),
                                          width: 30,
                                          height: 42,
                                        )
                                      : const SvgPathIcon(
                                          pathData: AppSvgPaths.fastForwardPart,
                                          viewBox: Size(28, 40),
                                          width: 28,
                                          height: 40,
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // دکمه جلو ( ۱۰ ثانیه به جلو یا آهنگ بعدی با نگه داشتن )
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _seekToSeconds(currentSeconds + 10),
                              onLongPress: () {
                                if (_tracks.isNotEmpty) {
                                  final nextIdx =
                                      (_currentIndex + 1) % _tracks.length;
                                  _playTrackAt(nextIdx);
                                }
                              },
                              child: const SizedBox(
                                width: 48,
                                height: 48,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: 4,
                                      child: SvgPathIcon(
                                        pathData: AppSvgPaths.fastForwardPart,
                                        viewBox: Size(28, 40),
                                        width: 28,
                                        height: 40,
                                      ),
                                    ),
                                    Positioned(
                                      left: 20,
                                      top: 4,
                                      child: SvgPathIcon(
                                        pathData: AppSvgPaths.fastForwardPart,
                                        viewBox: Size(28, 40),
                                        width: 28,
                                        height: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ۵. بخش آهنگ بعدی
                        _buildSectionHeader('آهنگ بعدی'),
                        const SizedBox(height: 10),
                        _buildTrackItem(
                          title: nextTrack.title,
                          artist: nextTrack.artist,
                          onTap: () {
                            if (_tracks.isNotEmpty) {
                              final nextIdx =
                                  (_currentIndex + 1) % _tracks.length;
                              _playTrackAt(nextIdx);
                            } else {
                              _pickAudioFiles();
                            }
                          },
                        ),

                        const SizedBox(height: 14),

                        // ۶. بخش آهنگ قبلی
                        _buildSectionHeader('آهنگ قبلی'),
                        const SizedBox(height: 10),
                        _buildTrackItem(
                          title: prevTrack.title,
                          artist: prevTrack.artist,
                          onTap: () {
                            if (_tracks.isNotEmpty) {
                              final prevIdx =
                                  (_currentIndex - 1 + _tracks.length) %
                                      _tracks.length;
                              _playTrackAt(prevIdx);
                            } else {
                              _pickAudioFiles();
                            }
                          },
                        ),

                        const Spacer(),
                        const SizedBox(height: 12),

                        // ۷. بخش تبلیغات پایین صفحه
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'تبلیغ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  'محل تبلیغ شما',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'برای ثبت تبلیغ کلیک کنید',
                                  style: TextStyle(
                                    color: Color(0xFF8FA0A6),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF52BDE0),
                                    Color(0xFF1B4F6B),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'تبلیغات',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVinylDisc({
    required double outerSize,
    required double imageSize,
    required double ringSize,
    required double pinkSize,
    required double holeSize,
  }) {
    return Container(
      width: outerSize,
      height: outerSize,
      decoration: const BoxDecoration(
        color: Color(0xFF060A12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: Image.network(
              albumCoverUrl,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: imageSize,
                height: imageSize,
                color: const Color(0xFF16202A),
              ),
            ),
          ),
          Container(
            width: ringSize,
            height: ringSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF060A12),
                width: 1,
              ),
            ),
          ),
          Container(
            width: pinkSize,
            height: pinkSize,
            decoration: const BoxDecoration(
              color: Color(0xFFDC2B7B),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: holeSize,
            height: holeSize,
            decoration: const BoxDecoration(
              color: Color(0xFF060A12),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 1,
          color: const Color(0xFF4B5767),
        ),
      ],
    );
  }

  // آیتم لیست آهنگ بعدی و قبلی (فاصله آیکون پلی از حاشیه چپ دقیقاً ۱۶ پیکسل)
  Widget _buildTrackItem({
    required String title,
    required String artist,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            const SvgPathIcon(
              pathData: AppSvgPaths.trackPlayLeft,
              viewBox: Size(21, 24),
              width: 21,
              height: 24,
            ),
            const Spacer(),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF52BDE0),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8FA0A6),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildVinylDisc(
              outerSize: 48,
              imageSize: 40,
              ringSize: 32,
              pinkSize: 8,
              holeSize: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class ArcProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  ArcProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      -math.pi,
      false,
      trackPaint,
    );

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final sweepAngle = -math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      progressPaint,
    );

    final thumbAngle = math.pi + sweepAngle;
    final thumbX = center.dx + radius * math.cos(thumbAngle);
    final thumbY = center.dy + radius * math.sin(thumbAngle);

    final thumbPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(thumbX, thumbY), 8, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant ArcProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
