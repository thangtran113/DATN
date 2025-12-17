import { Movie, VocabWord, QuizQuestion, Comment, CastMember } from './types';

// Images extracted from user prompt for fidelity
export const IMAGES = {
  hero: "https://lh3.googleusercontent.com/aida-public/AB6AXuB_o7_wG9X3msbfw5Lo9FvVB0r-TmVRxzYoO3XlkPZTLIYOXEAb-adHkdlz0Gg9vkSuy-Gug9ms9weR5yrRZ7r_hnXAvRMyVnXciBlKqeNKvukisXTmRAXty48NgwnoGE-TcRzGXojqxTYLWX9lemyiEssD9aCovZ4YhhrRkxjzGSDow0F4ujsAvuT_7H0_pZU34ah3AJe5Tr8QYREBJIiSoHNerp3lUNutuUxKudXa2WeQQc-Yqky1dmgnJi7LtukzNGhNqyVC_Wg",
  movie1: "https://lh3.googleusercontent.com/aida-public/AB6AXuC6mI9gixW-yub5E0l7FYN7mPyb0J17_twJQKev1tF8ccrQ6CVMQUbeMfj4ZrOq0j5uMUiKzLbKevg8DhUbBdK310boNrfDZfZ5nThoItyFntuIWuJYZM0jdr4Chb7nAV-s-jIgfhAvUPojf7FxcyyQZ-5Is7kLPI2b_248v8UMwsb0g9xbAjsG5S06uvz933KTHxwK52H876uUDZJHQmJb8I3pRiATwl9r10VqvrS6HOZ6HRkhQRYgKyxrUQiV-pZbGG-g0ZZvA8E",
  movie2: "https://lh3.googleusercontent.com/aida-public/AB6AXuAw0Fsoy8iz2IOK9KepkinRW6XDYjwvviBMoypoqvLDkLQ0i6MXPrDG-ZCFJHKybsHkZiFV0ChhJsDa8Jgwul0vjG5aY5R2rrPJgj-YiQFUsWHixkTrCHf74-xfO7ItDMSd6bJz3KDOMQDZhX4K6zVBTsz_8oG4UG7uvYAXkqTKIugIpt4us1p-wSH1J-e-Y2bVa7BFiugQyxJRAN3xrlp1LrhZk_zY13A1kenbdUDwrFnC0VoMFMAaKdjXSLulZIRPYdzJxVp59rA",
  movie3: "https://lh3.googleusercontent.com/aida-public/AB6AXuBZ3FgL-sCD9iqE_fNOQrMiAGLy22-29ChtCasl8GajSMb_Tb67m4f6qdOBJ9uIgP4K52HbksiGc51o_xb2Whsi94vb9mEcsq20gKvFKAh5EIymf6Cdh1jSidPxbRhPuFdd7-OoKC7VZYFiDc3aksLfvLE588rZ227DIK35ZyPlXRCzU_3wmdp_ImDGbdom1HDxkLT1ieXkqUHMwY7SCJE05foOKFPIwKtV7qok_Gu-0OWA2q15L-1or3986vRf2tqRgoENgmyfciM",
  movie4: "https://lh3.googleusercontent.com/aida-public/AB6AXuAvHK-IWOK9-bePsrJd0AH568D9FYggIkcpBFBSUwyEwyvDGOq3h8-a1MRzsTwpHMOkUjwVYDG0TI7LK2Ao2506tmDyZiNl7My7zayaUP15MR2JysM4V0qHLh7RPuJXXouhCgm0UwdYd_mSweFw5fWu1XqeO06oinqFTQubfTdpY8uDbXn3i06kIOInhHLLAN9lJSWj1dECj8Clpew5yjsOFDPgENOShTOR_HyIlmgi74TB5zlCgktsJ3lYXkhOzfle2A4g9Bc45xA",
  movieHero: "https://lh3.googleusercontent.com/aida-public/AB6AXuDrejjfz8G9zqbm8DcjzwHeudL9_mwS0k5mFZTulUMxQHpsklIUYjlc4ETzD3T_jJh3NCyJAdSy8Gfi4iEKxP7OGt4a0R0jnZmj9KvFdvXDssphqjhcmJM8vkUDGkFrkg-kUNE-UTWtZJ_CSgJn8a3ue2cCMAKOdeoPn8KFEC4ccroAZwQ0ibW_b2gOvCG6N93Id4O_b66Vm6m7yq1xk7CZ6TVAlc7E6o-52E2TcwzpgeHP8_ndSCUaY2a6LX9AVVU6SDFvlxDfJNw",
  avatar1: "https://lh3.googleusercontent.com/aida-public/AB6AXuBl9uyWugWOgQuF7_GCq8lK-5ad94k1N4NWSI5gMH21p_B3fthhujhAOublSNhO8r3rJlir-s-WR7L3nxPebl46qP23IC2nsEp-fRFvIHLuBIrXUMJp9hq4ZR9azehUceVbtUOaALH_3BhakreORHyR4ckW66vtvZKUIBBhphu1M6FAGWiOwJoilbKwGupR36SwKdCptWZdc8wEUOfqgN8R77eWGOMADZrDqQWdA9Qh92h_lkhYn8SEkMt951DQnU9MVut6kMupjT0",
  avatar2: "https://lh3.googleusercontent.com/aida-public/AB6AXuCxly1F8a-DbtRdbtJB3f6HQ5W-8KKf9uPKw794NbWlYNE4SwRCkTpJkD5YQ998pbns6oU5dk6HX5HmLCt3qpxNtV84xwNIG4rECe1ja0HPaQT-hhqAylW3b6WoLusv0uFcE_VCRiAgvwZPWGgpmJUDPjNGNIvli-ptOp8yEG2G-E-1cVW1bIvFr79BpfjkS1I-r1B2lqoAuS2H-azJbsDyofrcpd6SXz-8mPcGY3mc0H_C66ny-Z25kVIqh3uBJOj6PE1R6kP26IM",
  quizBg: "https://lh3.googleusercontent.com/aida-public/AB6AXuCgvrkuzhDDVBzeMPMET3s7OBmtLW8F5d5tDrq-gRIuTti372023qtqP6ayr5Ef9U6t6oECuWWP5Qn_b0cHVfrZ1HCK1PvVjDVbEwPLClSrvkWGJ0U0SkwO8XLYdbxvh4ApVrRGM8C5gc7QcXNfawjpQRhN8UDYoEwVanS4UQ_pxuBL9PeSDP5xBrlrVv9rwYEzwt_6PZjTj2kDdNwZf3AJPlxIBZ8GJhOVysYQYunaA96CIEeUaMjAUqSo1M8cvWc-DkuxShJsWCQ",
  card1: "https://lh3.googleusercontent.com/aida-public/AB6AXuDxHp4GaLkLsPl9UZSlnKjt_iaOUStsBgitMZnp1zPjGhbcUCixGSZqrcFTUwsQUeoJ2VetbKq2flJrAHWta1OQdlNY9ncZ6g4cDUF8kbUnaSW6kz2F5en8CSCgLmPRiP2h9LObpqNFACoB2FtqIDH9NRXs3yDZ08otUW_5oTbwOrCQh42eQ8mXV94f4JDnQtzoA64J6sJScS9LQVylc5FEndOYUsMa9TGcyyFX7v9f_AlOy6wMIH9O4gQ_wVc3QIwhuf7nBFfctrk"
}

export const MOVIES: Movie[] = [
  {
    id: 1,
    title: "The Midnight Enigma",
    description: "A thrilling mystery unfolds in the heart of the city, where secrets and suspense intertwine.",
    rating: 8.5,
    level: "Intermediate",
    coverUrl: IMAGES.movie1,
    backdropUrl: IMAGES.hero,
    year: 2023,
    duration: "1h 54m"
  },
  {
    id: 2,
    title: "Echoes of the Past",
    description: "A historian discovers a time portal.",
    rating: 7.9,
    level: "Advanced",
    coverUrl: IMAGES.movie2,
    backdropUrl: IMAGES.hero,
    year: 2022,
    duration: "2h 10m"
  },
  {
    id: 3,
    title: "The Last Frontier",
    description: "Survival in the deep wilderness.",
    rating: 9.1,
    level: "Beginner",
    coverUrl: IMAGES.movie3,
    backdropUrl: IMAGES.hero,
    year: 2024,
    duration: "1h 45m"
  },
  {
    id: 4,
    title: "City of Shadows",
    description: "Noir detective story in 1940s.",
    rating: 8.2,
    level: "Intermediate",
    coverUrl: IMAGES.movie4,
    backdropUrl: IMAGES.hero,
    year: 2021,
    duration: "2h 00m"
  },
  {
    id: 5,
    title: "Whispers in the Wind",
    description: "A romantic drama set in the countryside.",
    rating: 7.5,
    level: "Advanced",
    coverUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuDEwRORZzsF-8Di9_DxwJcQNRL4kZoKpxHGKCfRX-mDOSAV5fvDv3NHwTWyPLo8CC-98ug7IoZxSSBPcGwlNOdTWmdz27CdroYZsoyigfKhqysYbzfYKjoYpakanQ0LRACr-WMjczBZDptHJC5DBNnSnIMVjy8v3I6dpd52XCzx1rm4uhEafZBR02rMyWX9Z7kL_HmYiKEoERaZWuRvuDqtZzuQ8NmmnHUGH3_9e-tfARj2U6xbwF_Zv6aJxAH0fJ7C8TK3WgftIkk",
    backdropUrl: IMAGES.hero,
    year: 2020,
    duration: "1h 30m"
  },
];

export const VOCAB_LIST: VocabWord[] = [
  {
    id: 1,
    word: "Serendipity",
    definitionEn: "The occurrence and development of events by chance in a happy or beneficial way.",
    definitionVn: "Sự tình cờ may mắn",
    sourceImage: "https://lh3.googleusercontent.com/aida-public/AB6AXuC4V1F7NZKDViJyr_BuZ0AitWzxxs6tr5g836SLaY7D3iy2yO85IwaM5scKRMts2b831S_FKq4EyEQQPCq_ZyS7RHH-wX6mLXp-64jG0Nh-D1LlFPnaw9r-EHKUlBBzKEqzdnaPhVK9GoIHyubIkLMDSxC7bNKLMfygeYZZP4-6cd2rrQimH3OZ7CKEfQdAbeWzEajQOmDJRcn_osKfajZX1yBLsgOdXj0dg7RwGV0nkgeaS83A6UaeurZnSPI1DRyrwF2UF7O6F5M",
    level: 60,
    mastery: 'learning'
  },
  {
    id: 2,
    word: "Ephemeral",
    definitionEn: "Lasting for a very short time.",
    definitionVn: "Phù du, chẳng kéo dài",
    sourceImage: "https://lh3.googleusercontent.com/aida-public/AB6AXuCMkICj3rch6WU_2ZdQ_VtSkEguqZM2Z8TQHLXon4dKFZ_Ro6oiUjH-dwZRFt_Wrsy-F76EOiua1ZVfaeNZWcQ82Zn3OfZMhKLE9GW6zGPMEUFgRniNMvthjXQrQtWhOItHdUzo7GUA_FYCBRvQ-IjspBAlmxWnwnBSHRgZMvnWZwKdlU5CNvq7EUEO3Fx97-t5wAgx776dStZCH0h-evEZpybi-kOcrHOtOR1FbE2lqidHkXGMNqp87uugvgttPgEke2LYidgll7E",
    level: 20,
    mastery: 'new'
  },
  {
    id: 3,
    word: "Ubiquitous",
    definitionEn: "Present, appearing, or found everywhere.",
    definitionVn: "Phổ biến, khắp nơi",
    sourceImage: "https://lh3.googleusercontent.com/aida-public/AB6AXuC2wW8uFxJZqpUDOyiJd6_YzIGSwZv0D0deDF88yxerXhaBtO67ziQDvRkD2eIgf4VLYIe2H2WzuWv54sYWlignN5aqwF2qckPJw31xp7BoONXaOS5lsA_RjqPnXzQqtwKRa9vNKF8TVCE4l5e7a4BhwHhBiDN_XKiJfEHAy0oBmO4Z2x5wQuAwVJ-22QcFUTpL6-rJW1YfS8TqnPnO3Zbvni4EsiEp-Y3yiQYT0vtfjkWf0ZoXNmPswoIzD_JRJlwsAzY3rQ2F1HE",
    level: 80,
    mastery: 'mastered'
  }
];

export const COMMENTS: Comment[] = [
  {
    id: 1,
    user: "Liam Carter",
    avatarUrl: IMAGES.avatar1,
    timeAgo: "2 weeks ago",
    content: "This movie was amazing! The plot twists kept me on the edge of my seat.",
    likes: 12,
    dislikes: 2
  },
  {
    id: 2,
    user: "Sophia Reed",
    avatarUrl: IMAGES.avatar2,
    timeAgo: "3 weeks ago",
    content: "The visuals were stunning, and the acting was top-notch. A must-watch!",
    likes: 8,
    dislikes: 1
  }
];

export const CAST: CastMember[] = [
  { name: "Ava Sterling", imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuCgaFTFC5_6EvX4fDSLHXk3sHVr3KS4iwr-fnSr39k_pus5e74Lpczpz6RQThLmmXvbhr7S98q50QUrxcwwSbEwC8uJURYGNIdZpaYkL8Fv20urkcalHNd8QpPqbGciApGBM7U9r-NZ-QQVSEyY8bgBCqS9FzP2D8BU29BGJQ4s0Cv5_y9scKNzTTx4d9c7xHiWwW9thQMu436L5wNOVfq0ObOoe9zLr0I4LgRcrU8jiUTTkrNzUGKH6vAMbXUxIWan9P246X9prFs" },
  { name: "Ethan Blake", imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuB3dquc5tbQqAEhWS1yw8YA1aLSlPI-YFNGejvnLHtOPWw06s_n4PAQj7n99usU6W_r1EUuy4bpclvKW66B8031x3F4IEq5dgdVIqRuJv3gBNPdZABcWHALxGCa4QZaZmJ5nZ6UlBj8NLijPObL-XGmfx8OV2grR093RkrUdta0_q6bw8spmAL9UX6DwlrJmiZUHUF0auy3b9K6UqfxsrFsr8Mnfrok57r65rxZ80aQSwqTaF2HHqRRlM7-2xDkRkeUyYqBmfE2Csw" },
  { name: "Sophia Reed", imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuAslCWn_9XWH2tFy9PAFLw8pkOIXxfcQXhUu_aldw6xbQ_6418H0YLc3XVDly_HEyCft5hwKTe_56drUzNE9M4hckXHn7Gn7A-T6lPF0_wIOIjss4gD2FEe6K0idQK-5kDbfEQ2nQcZ-7XzA1SyYloJYYDnAHLAq6UAXDNMov4DLV6akgvZQUUs3ApcjK5r30baQUFHT43u5Sud8W5vOovY8AMQM2eIPilpM3ryeji2nO2-jgpKExEuB_ZtgI8vIYCgpunYHp8ZpIc" },
  { name: "Liam Carter", imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuD-QsIcPYStfKr0cPiSNMoim9lzc4hNMwEKHSGKypRtvCbZoQ1-7WNozKRbGdqD3T_jJh3NCyJAdSy8Gfi4iEKxP7OGt4a0R0jnZmj9KvFdvXDssphqjhcmJM8vkUDGkFrkg-kUNE-UTWtZJ_CSgJn8a3ue2cCMAKOdeoPn8KFEC4ccroAZwQ0ibW_b2gOvCG6N93Id4O_b66Vm6m7yq1xk7CZ6TVAlc7E6o-52E2TcwzpgeHP8_ndSCUaY2a6LX9AVVU6SDFvlxDfJNw" },
  { name: "Olivia Hayes", imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuCeZ0pOcpXSZp5h6uyk-Bjj0yuHh7NoDOtrhE98lESbVvG3O57OWyfC5Mao0yF1xv8mMuMaotQamym2o0h58MjYps4xR8-r5Oo2JvYr6YixElNJGnxEGGSxC-nzmoCbVqKHFf_dztAgKG-3c07DZGQoocEpTAnkANGNcrjqS7ZmTi7E8SLDRHLagYLX2qmAW8-bFfvFzN8NjUp5aU5QpXDNWOszMnDUNiNyJDncucTn4wkBFV_4YUol6M6Fys1uWXr__JeFzk_hBRs" },
];
