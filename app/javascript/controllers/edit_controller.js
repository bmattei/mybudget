import { Controller } from "@hotwired/stimulus";
import pluralize from 'pluralize';

export default class extends Controller {
    connect() {
        this.element.classList.add("editable");
    }

    editCell(event) {
        event.preventDefault();
        const cell = event.target;
        cell.contentEditable = true;
        cell.focus();
        cell.classList.add("bg-yellow-100");
    }

    editBooleanCell(event) {
        // No special handling needed here for checkbox
    }

    saveData(cell, newValue) {
        // Get the account ID from the data attribute
        const id = cell.dataset.id;
        const model = cell.dataset.model;

        // Example fetch request to update the account value
        const field = cell.dataset.field;

        // Construct the data to send in the request
        const data = {};
        data[model] = {};
        data[model][field] = newValue;
        const pluralModel = pluralize(model);
        const url = `/${pluralModel}/${id}`;
        const method = 'PATCH';
        const headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        };
        const body = JSON.stringify(data);

        console.log("URL:", url);
        console.log("Method:", method);
        console.log("Headers:", headers);
        console.log("Body:", body);

// Then, you can proceed to make the fetch request
        fetch(url, {
            method,
            headers,
            body
        })
            .then(response => {
                console.log(response);
            })
            .catch(error => {
                console.error(error);
            });
    }

    saveBooleanCell(event) {
        const checkbox = event.target;
        const cell = checkbox.closest('.table-cell');
        const newValue = checkbox.checked;
        this.saveData(cell, newValue);
    }

    saveCell(event) {
        const cell = event.target;
        cell.classList.remove("bg-yellow-100");
        const newValue = cell.textContent.trim();
        this.saveData(cell, newValue);
    }

    editReference(event) {
        event.preventDefault();
        if (event.target.tagName === 'SELECT') return;

        const cell = event.currentTarget;
        const selectElement = cell.querySelector('select');
        cell.querySelector('span').classList.add('hidden');
        selectElement.classList.remove('hidden');
        cell.classList.add('overflow-visible'); // Add overflow-visible class here
        selectElement.closest('.table-cell').classList.remove('overflow-visible')

        selectElement.focus();
    }
    saveReference(event) {
        const selectElement = event.target;
        const cell = selectElement.closest('.table-cell'); // Get the parent table-cell element
        const selectedValue = selectElement.value;
        const id = cell.dataset.id;
        const model = cell.dataset.model; // Access the data-controller-model attribute from the table cell
        const field = cell.dataset.field;
        selectElement.classList.add('hidden');
        cell.classList.remove('overflow-visible');

        cell.querySelector('span').classList.remove('hidden');
        cell.querySelector('span').textContent = selectElement.options[selectElement.selectedIndex].text;

        const data = {};
        data[model] = {}
        data[model][field] = selectedValue;
        const pluralModel = pluralize(model)

        fetch(`/${pluralModel}/${id}`, {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
            },
            body: JSON.stringify(data)
        })
            .then(response => {
                console.log(response);
            })
            .catch(error => {
                console.error(error);
            });
    }}
