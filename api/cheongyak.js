export const config = { runtime: "edge" };

export default async function handler(req) {
  const { searchParams } = new URL(req.url);
  const type = searchParams.get("type") || "apt";
  const sido = searchParams.get("sido") || "";
  const pageNo = searchParams.get("pageNo") || "1";
  const numOfRows = searchParams.get("numOfRows") || "10";

  const API_KEY = "ce12d20cefc1e376aa65c2ab8111cb5a249fbcbe8b9fa5b85afdbeb00a9ee681";

  const endpoints = {
    apt:      "https://apis.data.go.kr/1613000/AptBldgSttsService/getAptBldgStts",
    officetel:"https://apis.data.go.kr/1613000/OfctlAndDosiFormHousBldgSttsService/getOfctlAndDosiFormHousBldgStts",
    urban:    "https://apis.data.go.kr/1613000/UrbnRntHousBldgSttsService/getUrbnRntHousBldgStts",
    lodging:  "https://apis.data.go.kr/1613000/LivngHostHousBldgSttsService/getLivngHostHousBldgStts",
  };

  const base = endpoints[type] || endpoints.apt;
  const url = `${base}?serviceKey=${API_KEY}&sido=${sido}&pageNo=${pageNo}&numOfRows=${numOfRows}&_type=json`;

  const res = await fetch(url);
  const data = await res.json();

  return new Response(JSON.stringify(data), {
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}
