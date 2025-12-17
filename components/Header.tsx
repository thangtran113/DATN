import React from 'react';
import { Search, Bell, Menu } from 'lucide-react';
import { Link } from 'react-router-dom';

const Header = () => {
  return (
    <header className="flex items-center justify-between whitespace-nowrap border-b border-solid border-b-[#293142] px-4 md:px-10 py-3 bg-[#14171f]">
      <div className="flex items-center gap-4 lg:gap-8">
        <Link to="/" className="flex items-center gap-4 text-white hover:opacity-80 transition-opacity">
          <div className="size-8 md:size-6 flex items-center justify-center bg-[#293142] rounded">
             <div className="w-3 h-3 bg-white transform rotate-45"></div>
          </div>
          <h2 className="hidden md:block text-white text-lg font-bold leading-tight tracking-[-0.015em]">CineLingua</h2>
        </Link>
        <div className="hidden lg:flex items-center gap-9">
          <Link className="text-white text-sm font-medium leading-normal hover:text-blue-400 transition-colors" to="/">Home</Link>
          <Link className="text-white text-sm font-medium leading-normal hover:text-blue-400 transition-colors" to="/vocab">My Vocab</Link>
          <Link className="text-white text-sm font-medium leading-normal hover:text-blue-400 transition-colors" to="/admin">Admin</Link>
        </div>
      </div>
      
      <div className="flex flex-1 justify-end gap-4 md:gap-8">
        <label className="hidden sm:flex flex-col min-w-40 !h-10 max-w-64">
          <div className="flex w-full flex-1 items-stretch rounded-lg h-full">
            <div className="text-[#9ba6c0] flex border-none bg-[#293142] items-center justify-center pl-4 rounded-l-lg border-r-0">
              <Search size={20} />
            </div>
            <input
              placeholder="Search"
              className="form-input flex w-full min-w-0 flex-1 resize-none overflow-hidden rounded-lg text-white focus:outline-0 focus:ring-0 border-none bg-[#293142] focus:border-none h-full placeholder:text-[#9ba6c0] px-4 rounded-l-none border-l-0 pl-2 text-base font-normal leading-normal"
            />
          </div>
        </label>
        
        <button className="flex items-center justify-center text-white bg-[#293142] rounded-lg w-10 h-10 hover:bg-[#3b455e] transition-colors">
            <Bell size={20} />
        </button>

        <Link 
          to="/account"
          className="bg-center bg-no-repeat aspect-square bg-cover rounded-full size-10 border-2 border-transparent hover:border-white transition-all"
          style={{ backgroundImage: 'url("https://lh3.googleusercontent.com/aida-public/AB6AXuBHKEnIDm_d90mef-8iIoDx-tb44eMafNftW9ii9LHk1mJmWmw0kIiWjgHcfRzd1eDbnRxXkFvqMjNNbPTvPjg7SVq4yW4-0xDgX468rculaD3dJI50f_oGxRA71b2Lfb8g3_ssyQawkvyZqnZ41ZNYHBfYpaWFiIVpT7HQd86T8DyWCHv9eqDkVvQ_AqQ7Dyr770TE5LZ2oUGJxphl6Oz_DpZ6HhDZctovgY_tcBL0UK1pgXMrZJcJMAm10YZXXUgQyPmqQRvPWGg")' }}
        />
        
        <button className="lg:hidden text-white">
          <Menu />
        </button>
      </div>
    </header>
  );
};

export default Header;