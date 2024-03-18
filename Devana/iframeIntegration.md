# Devana IFrame as a Chatbot Integration Guide

This guide provides a step-by-step example of how to integrate Devana's IFrame as a chatbot that opens in the bottom right corner of your web application when a button is clicked. The chatbot will display the text "Devana Assistant Initializing" on a white background, with an "X Close" button in the top right corner. The chatbot's dimensions will be set to 400px width and height at 100%.

## Step 1: HTML Structure

Add the following HTML code to your web application to create the structure for the chatbot button and the IFrame:

```html
<button id="open-chatbot">Ask</button>

<div id="chatbot-container">
    <div id="chatbot-header">
        <button id="close-chatbot">X Close</button>
    </div>
    <iframe src="https://app.devana.ai/chat/{ID}/" id="devana-chatbot"></iframe>
</div>
```

Replace `{ID}` in the IFrame URL with your public agent's unique ID.

## Step 2: CSS Styling

Add the following CSS code to your application to style and position the chatbot and button:

```css
#chatbot-container {
    position: fixed;
    bottom: 20px;
    right: 20px;
    width: 400px;
    height: 400px;
    background-color: white;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    display: none;
    z-index: 9999;
}

#chatbot-header {
    display: flex;
    justify-content: flex-end;
    padding: 10px;
    border-bottom: 1px solid #f1f1f1;
}

#close-chatbot {
    background: none;
    border: none;
    color: #999;
    font-size: 14px;
    cursor: pointer;
}

#devana-chatbot {
    width: 100%;
    height: calc(100% - 40px);
    border: none;
}

#open-chatbot {
    position: fixed;
    bottom: 20px;
    right: 20px;
    padding: 10px 20px;
    background-color: #007bff;
    color: white;
    border: none;
    border-radius: 5px;
    font-size: 16px;
    cursor: pointer;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
}
```

## Step 3: JavaScript Event Handlers

Add the following JavaScript code to your application to handle the events for opening and closing the chatbot:

```javascript
const openChatbotButton = document.getElementById('open-chatbot');
const closeChatbotButton = document.getElementById('close-chatbot');
const chatbotContainer = document.getElementById('chatbot-container');

openChatbotButton.addEventListener('click', () => {
    chatbotContainer.style.display = 'block';
});

closeChatbotButton.addEventListener('click', () => {
    chatbotContainer.style.display = 'none';
});
```

## Result

With the above code in place, you will have an "Ask" button positioned at the bottom right corner of your web application. The button will have a blue background and white text. Clicking this button will open the Devana chatbot IFrame, also positioned at the bottom right corner. The chatbot will display the text "Devana Assistant Initializing" on a white background, and it will have an "X Close" button in the top right corner. The chatbot's dimensions will be set to 400px width and height at 100%.

That's it! You have now successfully integrated the Devana chatbot into your web application using an IFrame, meeting the specified requirements. Users can easily access the AI assistant by clicking the "Ask" button, providing them with a seamless and interactive experience.

For more advanced customization options and features, refer to the Devana IFrame [Integration Documentation](./iframe.md).


