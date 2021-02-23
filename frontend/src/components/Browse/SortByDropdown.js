import Dropdown from "react-bootstrap/Dropdown";
import DropdownButton from "react-bootstrap/DropdownButton";

function SortByDropdown(props) {
  return (
    <DropdownButton
      title={"Sort by: " + props.options[props.currentOption]}
      variant="outline-primary"
    >
      {props.options.map((option, index) => (
        <Dropdown.Item
          key={index}
          onClick={() => {
            props.setCurrentOption(index);
          }}
          eventKey={index}
        >
          {option}
        </Dropdown.Item>
      ))}
    </DropdownButton>
  );
}

export default SortByDropdown;
