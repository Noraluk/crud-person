import DataGrid, {
  Column,
  Editing,
  FormItem,
  Label,
  Scrolling,
} from "devextreme-react/data-grid";
import React, { useState } from "react";
import CustomStore from "devextreme/data/custom_store";

interface Person {
  id: number;
  first_name: string;
  last_name: string;
  latitude: string;
  longitude: string;
}

const initialData: Person[] = [];

export default function People() {
  const [data, setData] = useState<Person[]>(initialData);

  const people = new CustomStore({
    key: "id",
    load: () => data,
    insert: async (values) => {
      return new Promise((resolve, reject) => {
        if (navigator.geolocation) {
          navigator.geolocation.getCurrentPosition(
            (pos) => {
              const newData = {
                ...values,
                id: data.length + 1,
                latitude: pos.coords.latitude.toString(),
                longitude: pos.coords.longitude.toString(),
              };
              setData((prevData) => {
                const updatedData = [...prevData, newData];
                console.log(updatedData);
                return updatedData;
              });
              resolve(newData);
            },
            (err) => {
              console.log(err.message);
              reject(err);
            }
          );
        } else {
          console.log("Geolocation is not supported by this browser.");
          reject("Geolocation is not supported by this browser.");
        }
      });
    },
    update: async (key, values) => {
      return new Promise((resolve, reject) => {
        setData((prevData) => {
          const updatedData = prevData.map((item) =>
            item.id === key ? { ...item, ...values } : item
          );
          resolve(values);
          return updatedData;
        });
      });
    },

    remove: async (key) => {
      return new Promise((resolve, reject) => {
        setData((prevData) => {
          const updatedData = prevData.filter((item) => item.id !== key);
          resolve(key);
          return updatedData;
        });
      });
    },
  });

  return (
    <React.Fragment>
      <DataGrid
        id="grid"
        showBorders={true}
        dataSource={people}
        repaintChangesOnly={true}
      >
        <Editing
          refreshMode={"reshape"}
          mode="popup"
          allowAdding={true}
          allowDeleting={true}
          allowUpdating={true}
        />

        <Scrolling mode="virtual" />

        <Column dataField="first_name" />
        <Column dataField="last_name" />
        <Column
          dataField="latitude"
          allowEditing={false}
          caption="Latitude"
          editorOptions={{
            visible: false,
          }}
        >
          <FormItem>
            <Label text=" "></Label>
          </FormItem>
        </Column>
        <Column
          dataField="longitude"
          allowEditing={false}
          editorOptions={{
            visible: false,
          }}
        >
          <FormItem>
            <Label text=" "></Label>
          </FormItem>
        </Column>
      </DataGrid>
    </React.Fragment>
  );
}
