import Pagination from "react-bootstrap/Pagination";
import "./MoviePagination.css";
function MoviePagination(props) {
  function newPaginationItem(pageNumber) {
    return (
      <Pagination.Item
        onClick={() => props.pageChange(pageNumber)}
        key={pageNumber}
        active={pageNumber == props.pageNo}
      >
        {pageNumber}
      </Pagination.Item>
    );
  }
  let items = [
    <Pagination.First
      key={-2}
      disabled={props.pageNo == 1}
      onClick={() => props.pageChange(1)}
    />,
    <Pagination.Prev
      key={-1}
      disabled={props.pageNo == 1}
      onClick={() => props.pageChange(props.pageNo - 1)}
    />,
  ];

  let lastPage = Math.ceil(props.noOfResults / 12);
  var firstPage;
  if (props.pageNo < 4) {
    firstPage = 1;
  } else if (lastPage - props.pageNo < 9) {
    firstPage = lastPage - 9;
  } else {
    firstPage = props.pageNo - 2;
  }

  if (firstPage < 1) {
    firstPage = 1;
  }

  for (let number = firstPage; number <= lastPage; number++) {
    if (number - firstPage > 10 && number !== lastPage) {
      items.push(<Pagination.Ellipsis key={0} />);
      items.push(newPaginationItem(lastPage));
      items.push(
        <Pagination.Next
          key={lastPage + 1}
          onClick={() => props.pageChange(props.pageNo + 1)}
        />
      );
      items.push(
        <Pagination.Last
          key={lastPage + 2}
          onClick={() => props.pageChange(lastPage)}
        />
      );
      break;
    }
    items.push(newPaginationItem(number));
  }

  return <Pagination>{items}</Pagination>;
}

export default MoviePagination;
