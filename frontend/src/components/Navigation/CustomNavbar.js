import Navbar from "react-bootstrap/Navbar";
import Nav from "react-bootstrap/Nav";
import { LinkContainer } from "react-router-bootstrap";
import NavItem from "react-bootstrap/esm/NavItem";
import FormControl from "react-bootstrap/FormControl";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import "./CustomNavbar.css";

function CustomNavbar() {
  return (
    <Navbar className="main-navbar" bg="dark" expand="lg">
      <LinkContainer className="nav-link-text" to="/">
        <Navbar.Brand>Group 11</Navbar.Brand>
      </LinkContainer>
      <Navbar.Toggle aria-controls="basic-navbar-nav" />
      <Navbar.Collapse id="basic-navbar-nav">
        <Nav className="mr-auto">
          <LinkContainer className="nav-link-text" to="/browse">
            <NavItem>View Movies</NavItem>
          </LinkContainer>
          <LinkContainer className="nav-link-text" to="/popular">
            <NavItem>Popular</NavItem>
          </LinkContainer>
          <LinkContainer className="nav-link-text" to="/polarising">
            <NavItem>Polarising</NavItem>
          </LinkContainer>
          <LinkContainer className="nav-link-text" to="/use5">
            <NavItem>Use Case 5</NavItem>
          </LinkContainer>
          <LinkContainer className="nav-link-text" to="/use6">
            <NavItem>Use Case 6</NavItem>
          </LinkContainer>
        </Nav>
        <Form inline action={window.location.origin + "/browse"}>
          <FormControl type="text" placeholder="Search Movie" name="search" />
          <Button variant="outline-primary" type="submit">
            Search
          </Button>
        </Form>
      </Navbar.Collapse>
    </Navbar>
  );
}

export default CustomNavbar;
