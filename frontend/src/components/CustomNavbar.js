import Navbar from "react-bootstrap/Navbar";
import Nav from "react-bootstrap/Nav";
import { LinkContainer } from "react-router-bootstrap";
import NavItem from "react-bootstrap/esm/NavItem";
import FormControl from "react-bootstrap/FormControl";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";

function CustomNavbar() {
  return (
    <Navbar className="main-navbar" bg="light" expand="lg">
      <Navbar.Brand>Group 11</Navbar.Brand>
      <Navbar.Toggle aria-controls="basic-navbar-nav" />
      <Navbar.Collapse id="basic-navbar-nav">
        <Nav className="mr-auto">
          <LinkContainer className="nav-link-text" to="/">
            <NavItem>Home</NavItem>
          </LinkContainer>
          <LinkContainer className="nav-link-text" to="/browse">
            <NavItem>View movies</NavItem>
          </LinkContainer>
          <LinkContainer className="nav-link-text" to="/popular">
            <NavItem>Popular Now</NavItem>
          </LinkContainer>
          <LinkContainer className="nav-link-text" to="/released">
            <NavItem>Released soon</NavItem>
          </LinkContainer>
          <LinkContainer className="nav-link-text" to="/polarising">
            <NavItem>Polarising films</NavItem>
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
