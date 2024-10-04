// Variables
const body = document.getElementById('bodyy');
const Balancetxt = document.getElementById('BalanceSpan');

const items = [
    { name: 'nitrous', price: 25, TrustReq: 4, img: 'images/nitrous.png' },
    { name: 'sandwich', price: 25, TrustReq: 4, img: 'images/nitrous.png' }
    // Add more items here
];
let plrPriority = 100;
let cart = [];
let totalPrice = 0;

// Debounce function to limit how often the function can be called
function debounce(func, wait) {
    let timeout;
    return function(...args) {
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(this, args), wait);
    };
}

// Display items on the page
function displayItems() {
    let itemsTable = document.getElementById('itemsTable');
    items.forEach(item => {
        let itemBox = document.createElement('div');
        itemBox.className = 'item-box';

        let img = document.createElement('img');
        img.src = item.img;

        let itemName = document.createElement('p');
        itemName.innerText = item.name;

        let itemInfo = document.createElement('div');
        itemInfo.className = 'item-info';

        let itemPrice = document.createElement('p');
        itemPrice.innerText = 'Price: ₿' + item.price;

        let itemTrustReq = document.createElement('p');
        itemTrustReq.innerText = 'Priority: ' + item.TrustReq;

        itemInfo.appendChild(itemPrice);
        itemInfo.appendChild(itemTrustReq);

        let addButton = document.createElement('button');
        addButton.innerText = 'Add to Cart';
        addButton.onclick = () => addToCart(item);

        itemBox.appendChild(img);
        itemBox.appendChild(itemName);
        itemBox.appendChild(itemInfo);
        itemBox.appendChild(addButton);
        itemsTable.appendChild(itemBox);
    });
}

// Add item to cart
function addToCart(item) {
    if (item.TrustReq > plrPriority) {
        fetch('https://rx-blackmarket/js', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({ action: 'req', req: 'sendNotif', reason: 'treq' })
        })
        .then(response => response.json())
        .then(response => console.log(response))
        .catch(error => console.error('Error:', error));
        return;
    }

    let existingItem = cart.find(cartItem => cartItem.name === item.name);
    if (existingItem) {
        existingItem.quantity++;
    } else {
        cart.push({ ...item, quantity: 1 });
    }
    updateCart();
}

// Update cart display
function updateCart() {
    let cartTable = document.getElementById('cartTable').getElementsByTagName('tbody')[0];
    cartTable.innerHTML = '';
    totalPrice = 0;

    cart.forEach((item, index) => {
        let row = cartTable.insertRow();
        row.insertCell(0).innerText = item.name;

        let quantityCell = row.insertCell(1);
        let quantityDiv = document.createElement('div');
        quantityDiv.className = 'quantity-control';

        let downButton = document.createElement('button');
        downButton.innerText = '-';
        downButton.onclick = () => decreaseQuantity(index);

        let upButton = document.createElement('button');
        upButton.innerText = '+';
        upButton.onclick = () => increaseQuantity(index);

        let quantityDisplay = document.createElement('span');
        quantityDisplay.innerText = item.quantity;

        quantityDiv.appendChild(downButton);
        quantityDiv.appendChild(quantityDisplay);
        quantityDiv.appendChild(upButton);

        quantityCell.appendChild(quantityDiv);

        row.insertCell(2).innerText = '₿' + (item.price * item.quantity);
        row.insertCell(3).innerText = item.TrustReq;
        row.insertCell(4).innerHTML = `<button onclick="removeFromCart(${index})" class="btnbtn">Remove</button>`;
        totalPrice += item.price * item.quantity;
    });

    document.getElementById('totalPrice').innerText = '₿ ' + totalPrice;
}

// Increase item quantity
function increaseQuantity(index) {
    cart[index].quantity++;
    updateCart();
}

// Decrease item quantity
function decreaseQuantity(index) {
    if (cart[index].quantity > 1) {
        cart[index].quantity--;
    } else {
        cart.splice(index, 1);
    }
    updateCart();
}

// Remove item from cart
function removeFromCart(index) {
    cart.splice(index, 1);
    updateCart();
}

// Debounced submit order function
const debouncedSubmitOrder = debounce(function() {
    body.style.display = 'none';

    fetch('https://rx-blackmarket/js', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({ action: 'order', cart: cart, totalCrypto: totalPrice })
        })
        .then(response => response.json())
        .then(response => console.log('submitted'))
        .catch(error => console.error('Error:', error));

    clearCart();
}, 1000); // Adjust the wait time as needed (e.g., 1000 ms = 1 second)

// Trigger debounced submit order
function submitOrder() {
    debouncedSubmitOrder();
}

// Clear cart
function clearCart() {
    cart = [];
    updateCart();
}

// Handle close action
function handleClose() {
    clearCart();

    fetch('https://rx-blackmarket/js', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ action: 'ofucos', data: 'false' })
    })
    .then(response => response.json())
    .then(response => body.style.display = 'none')
    .catch(error => console.error('Error:', error));
}

// Display items when page loads
displayItems();
body.style.display = 'none';

// Handle messages from server
window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.type === 'req') {
        if (data.req === 'ShowLaptop') {
            body.style.display = 'block';
            Balancetxt.innerText = '₿' + data.balance;
            plrPriority = data.pio; // Update player priority
        } else if (data.req === 'HideLaptop') {
            body.style.display = 'none';
        }
    }
});
