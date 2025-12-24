import { Page, Locator } from '@playwright/test';

/**
 * Locators class for Wordle game elements.
 * Centralizes all element selectors for better maintainability.
 */
export class WordleLocators {
    readonly page: Page;

    // Modals
    readonly termsOfServiceModal: Locator;
    readonly termsOfServiceContinueButton: Locator;
    readonly playButton: Locator;
    readonly modalOverlay: Locator;
    readonly modalCloseButton: Locator;

    // Game Board
    readonly gameBoard: Locator;
    readonly boardRows: Locator;

    // Keyboard
    readonly enterKey: Locator;

    // Toast Messages
    readonly toastContainer: Locator;

    constructor(page: Page) {
        this.page = page;

        // Modal locators - prefer role-based and test-id selectors
        this.termsOfServiceModal = page.locator('.purr-blocker-card__content');
        this.termsOfServiceContinueButton = this.termsOfServiceModal.getByRole('button', { name: /continue/i });
        this.playButton = page.getByTestId('Play');
        this.modalOverlay = page.getByTestId('modal-overlay');
        this.modalCloseButton = this.modalOverlay.getByRole('button', { name: /close/i });

        // Game board locators - use more stable selectors when possible
        this.gameBoard = page.locator('.Board-module_board__jeoPS');
        this.boardRows = this.gameBoard.locator('.Row-module_row__pwpBq');

        // Keyboard locators - role-based for accessibility
        this.enterKey = page.getByRole('button', { name: /enter/i });

        // Toast container for notifications
        this.toastContainer = page.locator('#ToastContainer-module_gameToaster__HPkaC');
    }

    /**
     * Get a keyboard letter button by its character.
     * @param letter - The letter to find (case-insensitive)
     * @returns Locator for the keyboard letter button
     */
    getKeyboardLetterButton(letter: string): Locator {
        return this.page.getByLabel(`add ${letter.toLowerCase()}`);
    }

    /**
     * Get all tile elements within a specific row.
     * @param row - The row locator to search within
     * @returns Locator for all tiles in the row
     */
    getRowTiles(row: Locator): Locator {
        return row.getByTestId('tile');
    }
}
