import { clickBySelector } from '../helpers/actions';

// spec/cypress/e2e/guest_visit.cy.js
describe('Guest visit', () => {
  it('visit main pages', () => {
    // Visit the application under test
    cy.visit('/')
    cy.contains('Free to play fantasy sport games with friends')

    // visit privacy policy page
    clickBySelector('a[data-test-id="privacy-link"]')
    cy.contains('Privacy policy')

    // visit unauthorized page
    cy.visit('/draft_players')
    cy.contains('Permission is denied')

    // visit unexisting page
    cy.visit('/unexisting', { failOnStatusCode: false })
    cy.contains('Page is not found')
  })
})
