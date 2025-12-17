import React from 'react';
import { HashRouter, Routes, Route } from 'react-router-dom';
import Home from './pages/Home';
import MovieDetails from './pages/MovieDetails';
import Player from './pages/Player';
import Vocab from './pages/Vocab';
import Flashcard from './pages/Flashcard';
import Quiz from './pages/Quiz';
import Account from './pages/Account';
import Admin from './pages/Admin';

const App = () => {
  return (
    <HashRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/movie/:id" element={<MovieDetails />} />
        <Route path="/player/:id" element={<Player />} />
        <Route path="/vocab" element={<Vocab />} />
        <Route path="/flashcards" element={<Flashcard />} />
        <Route path="/quiz" element={<Quiz />} />
        <Route path="/account" element={<Account />} />
        <Route path="/admin" element={<Admin />} />
      </Routes>
    </HashRouter>
  );
};

export default App;
