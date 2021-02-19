import Pagination from "react-bootstrap/Pagination";

function MoviePagination(props) {
  function newPaginationItem(pageNumber) {
    return (
      <Pagination.Item
        onClick={() => props.pageChange(pageNumber)}
        key={pageNumber}
        active={pageNumber === props.pageNo}
      >
        {pageNumber}
      </Pagination.Item>
    );
  }

  let items = [
    <Pagination.First onClick={() => props.pageChange(1)} />,
    <Pagination.Prev onClick={() => props.pageChange(props.pageNo - 1)} />,
  ];

  let lastPage = Math.ceil(props.noOfResults / 10);

  for (let number = props.pageNo; number <= lastPage; number++) {
    if (number - props.pageNo > 10) {
      items.push(<Pagination.Ellipsis />);
      items.push(newPaginationItem(lastPage));
      items.push(
        <Pagination.Next onClick={() => props.pageChange(props.pageNo + 1)} />
      );
      items.push(
        <Pagination.Last onClick={() => props.pageChange(lastPage)} />
      );
      break;
    }
    items.push(newPaginationItem(number));
  }

  return <Pagination>{items}</Pagination>;
}

export default MoviePagination;
