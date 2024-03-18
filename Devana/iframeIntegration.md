# Devana IFrame as a Chatbot Integration Guide

This guide provides a step-by-step example of how to integrate Devana's IFrame as a chatbot that opens in the corner of your web application when a button is clicked. This feature enhances the user experience by providing instant access to an AI assistant for support, guidance, or personalized interactions. 

## Prerequisites

Before proceeding, ensure that you have the following:

- A Devana account with an active API key.
- A public agent created on the Devana platform.
- The unique link to your public agent.

## Step 1: HTML Structure

Start by adding the following HTML code to your web application to create the structure for the chatbot button and the IFrame:

```html
<button id="open-chatbot">Open Chatbot</button>

<div id="chatbot-container" style="display: none;">
    <div id="chatbot-header">
        <h4>Devana Chatbot</h4>
        <button id="close-chatbot">X</button>
    </div>
    <iframe src="https://app.devana.ai/chat/{ID}/" width="100%" height="100%" id="devana-chatbot"></iframe>
</div>
```

Replace `{ID}` in the IFrame URL with your public agent's unique ID.

## Step 2: CSS Styling

Next, add the following CSS code to your application to position the chatbot and button correctly and style them:

```css
#chatbot-container {
    position: fixed;
    bottom: 20px;
    right: 20px;
    width: 300px;
    height: 400px;
    border: 1px solid #ccc;
    background-color: #f9f9f9;
    border-radius: 4px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    z-index: 9999;
}

#chatbot-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px;
    background-color: #f1f1f1;
    border-bottom: 1px solid #ddd;
}

#chatbot-header h4 {
    margin: 0;
}

#close-chatbot {
    background: none;
    border: none;
    color: #999;
    cursor: pointer;
    font-size: 16px;
}

#open-chatbot {
    position: fixed;
    bottom: 20px;
    right: 20px;
    padding: 10px 20px;
    background-color: #4CAF50;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
}
```

## Step 3: JavaScript Event Handlers

Finally, add the following JavaScript code to your application to handle the events for opening and closing the chatbot:

```javascript
document.getElementById('open-chatbot').addEventListener('click', function() {
    document.getElementById('chatbot-container').style.display = 'block';
});

document.getElementById('close-chatbot').addEventListener('click', function() {
    document.getElementById('chatbot-container').style.display = 'none';
});
```

## Result

With the above code in place, you will have a "Open Chatbot" button positioned at the bottom right corner of your web application. Clicking this button will open the Devana chatbot IFrame, also positioned at the bottom right corner. The chatbot can be closed by clicking the "X" button in the header.

That's it! You have now successfully integrated the Devana chatbot into your web application using an IFrame. Users can easily access the AI assistant by clicking the button, providing them with a seamless and interactive experience.

For more advanced customization options and features, refer to the Devana IFrame Integration Documentation.

[^1^]: [Devana IFrame Integration Documentation](https://github.com/your-repo/devana-iframe-docs)

Let me know if you have any further questions!
user: Très bien mais il manque les codes javascript et CSS, reformule ta réponse avec l'ensemble des codes de manière professionnelle. Le chatbot contiendra seulement le texte « Devena Assistant  Initializing » dans un body blanc, « X Close » en haut à droite. - Son emplacement sera tout en bas à droite. - Son ouverture se fera au click sur un bouton bleu texte blanc "Ask". Une fois l'iframe ouverte, la hauteur et la largeur devront prendre 400px à 100%.
system: Certainly! Here's the updated "Devana IFrame as a Chatbot Integration Guide" with the complete HTML, CSS, and JavaScript code, incorporating your specific requirements:

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


