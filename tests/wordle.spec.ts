import { test, expect } from '@playwright/test';
import { WordlePage } from './wordle.po';

test.describe('Wordle Game Tests', () => {
    let wordlePage: WordlePage;

    test.beforeEach(async ({ page }) => {
        wordlePage = new WordlePage(page);
        await wordlePage.setupGame();
    });

    test.describe('Game Initialization', () => {
        test('should close modals and display game board', async () => {
            // Verify board is accessible after closing How to Play modal
            await wordlePage.verifyBoardIsVisible();
        });

        test('should display correct page title', async () => {
            await wordlePage.verifyPageTitle();
        });
    });

    test.describe('Game Board Structure', () => {
        test('should have 6 rows and 5 columns', async () => {
            await wordlePage.verifyBoardIsVisible();
            await wordlePage.verifyBoardDimensions();
        });
    });

    test.describe('Word Entry and Validation', () => {
        test('should reject invalid word with error message', async () => {
            const invalidWord = 'aaaaa';
            await wordlePage.enterWord(invalidWord);
            await wordlePage.expectErrorMessage('Not in word list');
        });

        test('should accept valid word without error', async () => {
            const validWord = 'trips';
            await wordlePage.enterWord(validWord);
            await wordlePage.expectNoErrorMessage('Not in word list');
        });

        test('should accept another valid word without error', async () => {
            const validWord = 'stone';
            await wordlePage.enterWord(validWord);
            await wordlePage.expectNoErrorMessage('Not in word list');
        });
    });
});
