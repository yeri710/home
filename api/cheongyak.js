export default async function handler(req, res) {
  const { type = "apt", sido = "" } = req.query;
  const API_KEY = "ce12d20cefc1e376aa65c2ab8111cb5a249fbcbe8b9fa5b85afdbeb00a9ee681";
  
  const endpoints = {
    apt: "https://apis.data.go.kr/1613000/AptBldgSttsService/getAptBldgStts",
    officetel: "https://apis.data.go.kr/1613000/OfctlAndDosiFormHousBldgSttsService/getOfctlAndDosiFormHousBldgStts",
    urban: "https://apis.data.go.kr/1613000/UrbnRntHousBldgSttsService/getUrbnRntHousBldgStts",
    lodging: "https://apis.data.go.kr/1613000/LivngHostHousBldgSttsService/getLivngHostHousBldgStts",
  };
  
  const url = `${endpoints[type] || endpoints.apt}?serviceKey=${API_KEY}&sido=${sido}&_type=json&numOfRows=10`;
  const response = await fetch(url);
  const data = await response.json();
  
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.json(data);
}
