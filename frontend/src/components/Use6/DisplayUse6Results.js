import PredictionsVsAverage from "./PredictionsVsAverage";

const traits = [
  "agreeableness",
  "conscientiousness",
  "emotional_stability",
  "extraversion",
  "openness",
];

function DisplayUse6Results(props) {
  if (!props.data) return <div />;
  const data = props.data;

  return (
    <div>
      {traits.map((item, index) => (
        <PredictionsVsAverage
          prediction={data[item]}
          average={data["average_" + item]}
          trait={item}
        />
      ))}
    </div>
  );
}

export default DisplayUse6Results;
