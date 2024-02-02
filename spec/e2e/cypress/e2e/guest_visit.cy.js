import { clickBySelector } from '../helpers/actions';

// spec/cypress/e2e/guest_visit.cy.js
describe('Guest visit', () => {
  it('visit main pages', () => {
    // Visit the application under test
    cy.visit('/')
    cy.contains('Fantasy Sports gives you the opportunity to run your own teams of professional players')

    // visit privacy policy page
    clickBySelector('a[data-test-id="guest-privacy-link"]')
    cy.contains('Privacy policy')

    // visit unauthorized page
    cy.visit('/home')
    cy.contains('Permission is denied')

    // visit unexisting page
    cy.visit('/unexisting', { failOnStatusCode: false })
    cy.contains('Page is not found')
  })
})
