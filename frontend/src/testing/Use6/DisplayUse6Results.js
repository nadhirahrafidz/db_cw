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
  console.log(data);

  return (
    <div>
      {traits.map((trait, index) => (
        <div key={index}>
          <PredictionsVsAverage
            trait={trait}
            predictions={data.predictions}
            average={data.averages}
          />
        </div>
      ))}
    </div>
  );
}

export default DisplayUse6Results;
