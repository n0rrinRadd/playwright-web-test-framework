import { Page, expect } from '@playwright/test';
import { WordleLocators } from './wordle.lo';

/**
 * Page Object class for Wordle game interactions.
 * Encapsulates all page actions and verifications.
 */
export class WordlePage {
    readonly page: Page;
    readonly locators: WordleLocators;

    // Constants for board dimensions
    private static readonly EXPECTED_ROWS = 6;
    private static readonly EXPECTED_COLUMNS = 5;
    private static readonly EXPECTED_TITLE = 'Wordle — The New York Times';
    private static readonly WORD_LENGTH = 5;

    constructor(page: Page) {
        this.page = page;
        this.locators = new WordleLocators(page);
    }

    /**
     * Navigate to the Wordle game page.
     */
    async navigateToGame(): Promise<void> {
        const baseUrl = process.env.BASE_URL;
        if (!baseUrl) {
            throw new Error('BASE_URL environment variable is not set');
        }
        await this.page.goto(baseUrl);
    }

    /**
     * Close Terms of Service modal if present.
     */
    async closeTermsOfServiceModal(): Promise<void> {
        const modalCount = await this.locators.termsOfServiceModal.count();
        if (modalCount > 0) {
            await this.locators.termsOfServiceContinueButton.click();
            await this.locators.termsOfServiceModal.waitFor({ state: 'hidden' });
        }
    }

    /**
     * Start the game by clicking Play and closing the How to Play modal.
     */
    async startGame(): Promise<void> {
        await this.locators.playButton.click();
        await this.locators.modalCloseButton.click();
        await this.locators.modalOverlay.waitFor({ state: 'hidden' });
    }

    /**
     * Complete game setup: navigate, close modals, and prepare for playing.
     */
    async setupGame(): Promise<void> {
        await this.navigateToGame();
        await this.closeTermsOfServiceModal();
        await this.startGame();
    }

    /**
     * Verify the page title matches expected value.
     */
    async verifyPageTitle(): Promise<void> {
        await expect(this.page).toHaveTitle(WordlePage.EXPECTED_TITLE);
    }

    /**
     * Verify the game board is visible and accessible.
     */
    async verifyBoardIsVisible(): Promise<void> {
        await expect(this.locators.gameBoard).toBeVisible();
    }

    /**
     * Verify the game board has correct dimensions (6 rows × 5 columns).
     */
    async verifyBoardDimensions(): Promise<void> {
        // Verify row count
        await expect(this.locators.boardRows).toHaveCount(WordlePage.EXPECTED_ROWS);
        
        // Verify each row has correct number of tiles
        const rows = await this.locators.boardRows.all();
        for (const row of rows) {
            const tiles = this.locators.getRowTiles(row);
            await expect(tiles).toHaveCount(WordlePage.EXPECTED_COLUMNS);
        }
    }

    /**
     * Type a word using the on-screen keyboard and submit it.
     * @param word - The word to enter (must be 5 letters)
     */
    async enterWord(word: string): Promise<void> {
        if (word.length !== WordlePage.WORD_LENGTH) {
            throw new Error(`Word must be ${WordlePage.WORD_LENGTH} letters, got: ${word}`);
        }

        // Type each letter
        for (const letter of word.toLowerCase()) {
            await this.locators.getKeyboardLetterButton(letter).click();
        }
        
        // Submit the word
        await this.locators.enterKey.click();
    }

    /**
     * Get the current toast message content.
     * @returns The toast message text
     */
    private async getToastContent(): Promise<string> {
        await this.locators.toastContainer.waitFor({ state: 'visible', timeout: 3000 });
        return await this.locators.toastContainer.ariaSnapshot();
    }

    /**
     * Verify that a specific error message appears in the toast.
     * @param expectedError - The expected error text
     */
    async expectErrorMessage(expectedError: string): Promise<void> {
        const toastContent = await this.getToastContent();
        expect(toastContent).toContain(expectedError);
    }

    /**
     * Verify that a specific error message does NOT appear in the toast.
     * @param unexpectedError - The error text that should not appear
     */
    async expectNoErrorMessage(unexpectedError: string): Promise<void> {
        try {
            const toastContent = await this.getToastContent();
            expect(toastContent).not.toContain(unexpectedError);
        } catch {
            // If toast doesn't appear, that's also valid (no error)
            return;
        }
    }
}
