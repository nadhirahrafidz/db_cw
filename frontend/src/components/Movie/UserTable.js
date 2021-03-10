import Table from "react-bootstrap/Table";
import "./AudienceSegmentation.css";

function UserTable(props) {
  if (props.data) {
    return (
      <div className="table-container">
        <Table striped bordered hover variant="dark">
          <thead>
            <tr>
              <th>User ID</th>
              <th>Similar Movie Rating</th>
              <th>This Movie Rating</th>
            </tr>
          </thead>
          <tbody>
            {props.data.map((item) => (
              <tr key={item.user_id}>
                <td>{item.user_id}</td>
                <td>{item.similar_movie_rating}</td>
                <td>{item.this_movie_rating}</td>
              </tr>
            ))}
          </tbody>
        </Table>
      </div>
    );
  }
  return <div />;
}

export default UserTable;
