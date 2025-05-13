// Phillip Mantatsky 3/31/2025
// This project uses various text files that have red light cameras and organizes them in different ways
// The cases output the amount of cameras, violations, and the addresses and streets of each camera
// This project organizes this data and outputs it in a way the user can read.

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <cctype>



using namespace std;

//This class reresents a record for a camera at an intersection 
// as well as methods to process and sort information about traffic violations
class CameraRecord {
    public:
        // Sets the data for the currect record using string inputs
        // The strings are alter converted into their repsective types
        void setData(string intersection, string address,
        string camNum, string date, string numViolations, string neighborHood);
        // Maintains a unique list of camera IDs
        // It updates the classCamID and classCamNum to reflect unique cameras encountered
        void cameraID(int camNum);
        // Updates the record for the day with most violations
        void mostNumViolations();
        // Returns the total number of unique cameras
        int getCameraNum();
        // Returns the max num of violations that occured in a single day
        int getMostNumViolations();
        // Returns the date on which the most violations occured
        string getMostDateViolations();
        // returns the intersection where the most violations occured
        string getMostIntersectionViolations();
        //Sorts data by neighborhood. updates static vectors for neighborhoods, violations,
        // and camera counts. also sorts the neighborhoods by num of violations
        void data();
        //Updates a static vector that holds the num of violations per month
        void checkMonthViolations();
        // searches and collects camera records that match a given neighborhood
        void checkNeighborhoodData(string neighborhood);
        // Static getters for retrieving sorted data stored in static vecotrs
        static vector<string>& getNeighborhoods();
        static vector<int>& getNeighborhoodCameras();
        static vector<int>& getNeighborhoodViolations();
        static vector<int>& getViolationsPerMonth();
        static vector<string>& getIndividualNeighborData();
    private:
    // Member variables for storing detaiuls about each camera record
        string classIntersection; // intersection where the camera is located
        string mostIntersectionViolation; // intersecction associated with highest daily violations
        string mostDateViolation; // Date on which the most violations occured
        int mostNumViolations1 = 0; // highest num of violations observed
        string classAddress; // address of cam
        int classCamNum = 0; // num of unique cams
        string classDate; // date of record
        int classNumViolations = 0; // num of violations recorded
        string classNeighborhood; // neighborhood associated with record
        static vector<string> neighborhoods; // liost of unique neighborhoods encountered
        static vector<int> neighborhoodCameras; // count of unique cams per neighborhood
        static vector<int> neighborhoodViolations; // sum of violations per neighborhood
        static vector<int> violationsPerMonth; // total violations per month
        static vector<string> individualNeighborData; // detailed records, cam ids and data
        int classCamID; // unique id for each camera record
};
// initialization of static members
vector<string> CameraRecord::neighborhoods;
vector<int> CameraRecord::neighborhoodViolations;
vector<int> CameraRecord::neighborhoodCameras;
// vector with 12 elements 1 for each month
vector<int> CameraRecord::violationsPerMonth(12, 0);
vector<string> CameraRecord::individualNeighborData;

// assigns values from parameters to the class members
// convertsd camNum and numViolations from str to int
void CameraRecord::setData(string intersection, string address,
        string camNum, string date, string numViolations, string neighborHood) {
            classIntersection = intersection;
            classAddress = address;
            classCamNum = stoi(camNum);
            classDate = date;
            classNumViolations = stoi(numViolations);
            classNeighborhood = neighborHood;
}

//Maintains a static lirt of unique cam ids
// if current cam (camNum) is not alread in list, it is added
// Then, classCamNum is updated to be the size of the unique cam list
void CameraRecord::cameraID(int camNum) {
    static vector<int> cameras; // local static vector to store unique cam ids
    bool found = false;
    classCamID = camNum; // set the instance's cam id
    if (cameras.size() == 0) {
        cameras.push_back(camNum);
    }
    else {
        // check if the cam has already been added
        for (int i = 0; i < cameras.size(); i++) {
            if (cameras.at(i) == camNum) {
                found = true;
                break;
            }
        }
        if (!found) {
            cameras.push_back(camNum);
        }
    }
    // update the class cam count to the num of unique cams
    classCamNum = cameras.size();
    }

// returns the num of unique cams
int CameraRecord::getCameraNum() {
    return classCamNum;
}

// updates the record if the current record has more violations than the current max
void CameraRecord::mostNumViolations() {
    if (mostNumViolations1 < classNumViolations) {
        mostNumViolations1 = classNumViolations;
        mostDateViolation = classDate;
        mostIntersectionViolation = classIntersection;
    }
}

// returns the highest num of violation recorded in a day
int CameraRecord::getMostNumViolations() {
    return mostNumViolations1;
}

// formats and returns the date associated with the most violations
// swaps the parts of the date string
string CameraRecord::getMostDateViolations() {
    int index = mostDateViolation.find("-");
    // create a new date string by swapping parts
    string newDate = mostDateViolation.substr(index + 1);
    newDate += "-";
    newDate += mostDateViolation.substr(0, index);
    // update mostDateViolation with the formatted date
    mostDateViolation = newDate;
    return mostDateViolation;
}

// extracts the month from classDate and updates the static monthly violations count
// the month is determined by parsing the string between the first and second '-' characters
void CameraRecord::checkMonthViolations() {
    int index = classDate.find("-");
    string newDate = classDate.substr(index + 1);
    newDate = newDate.substr(0, newDate.find("-"));
    int newDateInt = stoi(newDate);
    violationsPerMonth.at(newDateInt - 1) += classNumViolations;
}

// provides access to the monthly violations vector
vector<int>& CameraRecord::getViolationsPerMonth() {
    return violationsPerMonth;
}

// returns the intersection where the most violations occured
string CameraRecord::getMostIntersectionViolations() {
    return mostIntersectionViolation;
}

// sorts neighborhood data
// it checks if the current record's neighborhood has been encountered
// if not, it adds the neighborhood to the list and initializes its data
// also, it keeps track of unique cameras per neighborhood and updates the num of violations
// sorts the neighborhoods in descending order of total violations
void CameraRecord::data() {
    bool found = false;
    int index = 0;
    static vector<int> cameraID; // track which cam ids have been used

    // check if the neighborhood already exists 
    for (int i = 0; i < neighborhoods.size(); i++) {
        if (neighborhoods.at(i) == classNeighborhood) {
            found = true;
            index = i;
            break;
        }
    }
    bool cameraCounted = false;
    
    // check if the cam id has already been accounted for
    for (int i = 0; i < cameraID.size(); i++) {
        if (cameraID.at(i) == classCamID) {
            cameraCounted = true;
            break;
        }
    }

    if (found != true) {
        // if the neighborhood is new, add it along with its initial violation count
        neighborhoods.push_back(classNeighborhood);
        neighborhoodViolations.push_back(classNumViolations);
        if (!cameraCounted) {
        neighborhoodCameras.push_back(1);
        cameraID.push_back(classCamID);
        }
    }
    else {
        // if the neighborhood already exists update its total violations
       neighborhoodViolations.at(index) += classNumViolations;
       // if this cam hasnt been counted yet for this neighborhood, update the the cam count
       if (!cameraCounted) {
       neighborhoodCameras.at(index) += 1;
       cameraID.push_back(classCamID);
       }
    }

    // sort the neighborhood data by total violatiopns in descending order
    for (int i = 0; i < neighborhoodViolations.size(); i++) {
        for (int j = i + 1; j < neighborhoodViolations.size(); j++) {
            if (neighborhoodViolations.at(i) < neighborhoodViolations.at(j)) {
                // swap violation counts;
                int tempViolations = neighborhoodViolations.at(i);
                neighborhoodViolations.at(i) = neighborhoodViolations.at(j);
                neighborhoodViolations.at(j) = tempViolations;

                // swap the camera counts accordingly
                int tempCameras = neighborhoodCameras.at(i);
                neighborhoodCameras.at(i) = neighborhoodCameras.at(j);
                neighborhoodCameras.at(j) = tempCameras;

                //swap neighborhood names
                string tempName = neighborhoods.at(i);
                neighborhoods.at(i) = neighborhoods.at(j);
                neighborhoods.at(j) = tempName;
        }
        }
    }
}

// searches for a given string within the neighborhood or intersection
// search is case insensitive, if match is found and the cam hasnt already been added, it is
void CameraRecord::checkNeighborhoodData(string neighborhood) {
    string lowerClassNeighborhood;
    string lowerNeighborhood;
    string lowerClassIntersection;
    // convert classNeighborhood to lowercase
    for (char a : classNeighborhood) {
        lowerClassNeighborhood += tolower(a);
    }
    // convert search term to lowercase
    for (char a : neighborhood) {
        lowerNeighborhood += tolower(a);
    }
    for (char a : classIntersection) {
        lowerClassIntersection += tolower(a);
    }
    bool alreadyExists = false;
    for (int i = 0; i < individualNeighborData.size(); i++) {
        // check if the cam id is already present in the detailed search data
        if (individualNeighborData.at(i) == to_string(classCamID)) {
            alreadyExists = true;
            break;
        }
    }
    // if not alreadey recorded and a match is found 
    // then add the camera's details to the individualNeighborhoodData vector
    if (!alreadyExists) {
        if (lowerClassNeighborhood.find(lowerNeighborhood) != string::npos || lowerClassIntersection.find(lowerNeighborhood) != string::npos) {
            individualNeighborData.push_back(to_string(classCamID));
            individualNeighborData.push_back(classAddress);
            individualNeighborData.push_back(classIntersection);
            individualNeighborData.push_back(classNeighborhood);
            }
    }
    }
    

// getter for the static vector containing unique neighborhood names
vector<string>& CameraRecord::getNeighborhoods() {
    return neighborhoods;
}

// getter for the static vector containing the count of cams per neighborhood
vector<int>& CameraRecord::getNeighborhoodCameras() {
    return neighborhoodCameras;
}

// getter for vector containing total violations per neighborhood
vector<int>& CameraRecord::getNeighborhoodViolations() {
    return neighborhoodViolations;
}

//getter for vector containing individual cam data
vector<string>& CameraRecord::getIndividualNeighborData(){
    return individualNeighborData;
}



int main() {
    CameraRecord currStopLight; // instance of CameraRecord to process each record
    int currCamNum; // temp storage for cam num
    int currNumViolations; // temp storage for num of violations
    string token;
    vector<string> dataList;
    string text;
    dataList.resize(6); 
    int count = 0;
    int totalViolations = 0;

    // prompt user to enter file name
    cout << "Enter file to use: ";
    cin >> text;
    cout << endl;
    ifstream fileIn;
    fileIn.open(text);
    int choice;
    int fileReadOnce = 0;
    // main loop for menu options, loop exits when user enters 5
    while (choice != 5) {
    // display menu options
    cout << "Select a menu option: " << endl;
    cout << "  1. Data overview" << endl;
    cout << "  2. Results by neighborhood" << endl;
    cout << "  3. Chart by month" << endl;
    cout << "  4. Search for cameras" << endl;
    cout << "  5. Exit" << endl;
    cout << "Your choice: ";
    cin >> choice;
    string neighborhoods;
    // for search option clear previous search data and re read file
    if(choice == 4) {
        currStopLight.getIndividualNeighborData().clear();
        cout << "What should we search for? ";
        cin.ignore();
        getline(cin, neighborhoods);
        cout << endl;
        fileIn.close();
        fileIn.open(text);
    }
    
    // process file until end is reached
    while (!fileIn.eof()) {
        // read 6 tokens from file corresponding to each record
        for (int i = 0; i < 6; i++) {
            // for the last field, read until end of line
            if (i == 5) {
                getline(fileIn, token, '\n');
                dataList.at(i) = token;
            }
            // for other fields, read tokens seperated by commas
            else {
                getline(fileIn, token, ',');
                dataList.at(i) = token;
            }
        }
        // gather and put data into setData from file reading
        currStopLight.setData(dataList.at(0), dataList.at(1), dataList.at(2), dataList.at(3), 
        dataList.at(4), dataList.at(5));
        // convert cam num from str to int
        currCamNum = stoi(dataList.at(2));
        // update unique cam list
        currStopLight.cameraID(currCamNum);
        // check if the record matches the neighborhood search criteria
        currStopLight.checkNeighborhoodData(neighborhoods);
        // only update overall stats the first time through file
        if (fileReadOnce == 0) {
            currNumViolations = stoi(dataList.at(4));
            totalViolations += currNumViolations;
            currStopLight.mostNumViolations();
            count++;
            currStopLight.checkMonthViolations();
            currStopLight.data();
        }
    }
    fileReadOnce++;
    // get data for outputs
    vector<string> neighborhood = currStopLight.getNeighborhoods();
    vector<int> neighborhoodCameras = currStopLight.getNeighborhoodCameras();
    vector<int> neighborhoodViolations = currStopLight.getNeighborhoodViolations();
    vector<int> monthlyViolations = currStopLight.getViolationsPerMonth();
    vector<string> neighborhoodData = currStopLight.getIndividualNeighborData();

    vector<string> months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};

    if (choice == 1) {
        // display count of records, unique cams, total violations 
        // and details about record with most violations
        cout << "Read file with " << count << " records." << endl;
        cout << "There are " << currStopLight.getCameraNum() << " cameras." << endl;
        cout << "A total of " << totalViolations << " violations." << endl;
        cout <<  "The most violations in one day were "<< currStopLight.getMostNumViolations() << " on " << currStopLight.getMostDateViolations() << " at " << currStopLight.getMostIntersectionViolations() << endl;
    }
    else if (choice == 2) {
        // display results by neighborhood
        for (int i = 0; i < neighborhood.size(); i++) {
            int spaces = neighborhood.at(i).length();
            spaces = 25 - spaces;
            int spaces2 = to_string(neighborhoodViolations.at(i)).length();
            spaces2 = 7 - spaces2;
            int spaces3 = to_string(neighborhoodCameras.at(i)).length();
            spaces3 = 4 - spaces3;
            cout << neighborhood.at(i) << string(spaces, ' ') << string(spaces3, ' ') << neighborhoodCameras.at(i) << string(spaces2, ' ') << neighborhoodViolations.at(i) << endl;
        }
    }
    else if(choice == 3) {
        // display chart of monthly violations
        for (int i = 0; i < monthlyViolations.size(); i++) {
            int star = monthlyViolations.at(i) / 1000;
            cout << months.at(i) << " " << string(star, '*') << endl;
        }
    }
    else if(choice == 4) {
        // display search results for cam records matching the search term
        if (neighborhoodData.size() == 0) {
            cout << "No cameras found." << endl;
        }
        else {
            // each record contains cam id, address, intersection, and neighborhood
            for (int i = 0; i < neighborhoodData.size(); i += 4) {
                cout << "Camera: " << neighborhoodData.at(i) << endl;
                cout << "Address: " << neighborhoodData.at(i+1) << endl;
                cout << "Intersection: " << neighborhoodData.at(i+2) << endl;
                cout << "Neighborhood: " << neighborhoodData.at(i+3) << endl;
                cout << endl;
            }
            cout << endl;
         }
        }
    }
    }
