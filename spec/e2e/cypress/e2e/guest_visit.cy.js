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

    // visit russian localization
    cy.visit('/')
    cy.contains('Free to play fantasy sport games with friends')
    // click changing locale
    clickBySelector('a[data-test-id="switch-locale-link-ru"]')
    cy.contains('Соревнуйтесь с друзьями в фэнтези спорте')
    // change url directly - russian locale is used from cookies
    cy.visit('/privacy')
    cy.contains('Политика конфиденциальности')
    clickBySelector('a[data-test-id="switch-locale-link-en"]')
    cy.visit('/privacy')
    cy.contains('Privacy policy')
    cy.visit('/ru/privacy')
    // locale from cookies is not used when locale in url is not default
    cy.contains('Политика конфиденциальности')
  })
})
