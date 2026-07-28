// assets/js/hooks/draggable_hook.js

export const Draggable = {
  mounted() {
    this.el.style.cursor = "grab";
    sticker = document.getElementById(this.el.id.replace("sticker-drag-", "sticker-"));
    // Находим нашего родителя-контейнера
    const board = document.getElementById("board");
    if (!board) {
      console.error("Board element not found!");
      return;
    }

    let isDragging = false;
    let offsetX, offsetY;

    const startDrag = (e) => {
      e.preventDefault();
      sticker = document.getElementById(this.el.id.replace("sticker-drag-", "sticker-"));
      isDragging = true;
      this.el.style.cursor = "grabbing";
      sticker.style.zIndex = 1000;

      // Получаем координаты родителя ("доски")
      const boardRect = board.getBoundingClientRect();

      // Вычисляем смещение курсора относительно ЛЕВОГО ВЕРХНЕГО УГЛА РОДИТЕЛЯ
      const cursorXInBoard = e.clientX - boardRect.left;
      const cursorYInBoard = e.clientY - boardRect.top;
      
      // Вычисляем смещение курсора относительно ЛЕВОГО ВЕРХНЕГО УГЛА СТИКЕРА
      offsetX = cursorXInBoard - sticker.offsetLeft;
      offsetY = cursorYInBoard - sticker.offsetTop;
    };

    const drag = (e) => {
      if (!isDragging) return;
      sticker = document.getElementById(this.el.id.replace("sticker-drag-", "sticker-"));
      const boardRect = board.getBoundingClientRect();

      const cursorXInBoard = e.clientX - boardRect.left;
      const cursorYInBoard = e.clientY - boardRect.top;

      // Вычисляем новую позицию стикера ВНУТРИ родителя
      const newX = cursorXInBoard - offsetX;
      const newY = cursorYInBoard - offsetY;
      
      sticker.style.left = newX + "px";
      sticker.style.top = newY + "px";
    };  

    const endDrag = (e) => {
      if (isDragging) {
        isDragging = false;
        sticker = document.getElementById(this.el.id.replace("sticker-drag-", "sticker-"));
        this.el.style.cursor = "grab";
        sticker.style.zIndex = "auto";
        
        const boardRect = board.getBoundingClientRect();
        
        const cursorXInBoard = e.clientX - boardRect.left;
        const cursorYInBoard = e.clientY - boardRect.top;
  
        // Вычисляем новую позицию стикера ВНУТРИ родителя
        const newX = cursorXInBoard - offsetX;
        const newY = cursorYInBoard - offsetY;
        
        // Отправляем на сервер координаты, которые имеют смысл ВНУТРИ ДОСКИ
        this.pushEvent("move_sticker", {
          id: this.el.id.replace("sticker-drag-", ""),
          x: newX,
          y: newY,
        });
      }
    };
    
    this.el.addEventListener("mousedown", startDrag);
    window.addEventListener("mousemove", drag);
    window.addEventListener("mouseup", endDrag);
    
    this.destroyed = () => {
          window.removeEventListener("mousemove", drag);
          window.removeEventListener("mouseup", endDrag);
        };
  }
};