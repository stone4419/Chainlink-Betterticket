 async function addPoints() {
    const { lastCollected, daysInARow, Points } = data.attributes;

    if (!lastCollected || !moment(lastCollected).isSame(moment.utc(), "day")) {
      data.increment("points", days[daysInARow]);
      data.set("lastCollected", moment.utc().format());
      setCollected(true);
      setUserPoints(points + days[daysInARow]);
      if (daysInARow === 6) {
        data.set("daysInARow", 0);
        setDaysStreak(0);
      } else {
        setDaysStreak(daysInARow + 1);
        data.increment("daysInARow");
      }
      data.save();
      succCollect(days[daysInARow]);
    } else {
      failCollect();
    }
  }

  function succCollect() {
    let secondsToGo = 5;
    const modal = Modal.success({
      title: "Success!",
      content: (
        <>
          <p>You have collected some points</p>
        </>
      ),
    });
    setTimeout(() => {
      modal.destroy();
    }, secondsToGo * 1000);
  }

  function failCollect() {
    let secondsToGo = 5;
    const modal = Modal.error({
      title: "Hold Up!",
      content: `You can only collect points once a day, please come back tomorrow`,
    });
    setTimeout(() => {
      modal.destroy();
    }, secondsToGo * 1000);
  }
