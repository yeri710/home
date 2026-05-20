import { useState, useEffect, useCallback, useRef } from "react";

const API_KEY = "YOUR_API_KEY_HERE";

// 주거유형별 API 엔드포인트
const API_ENDPOINTS = {
  apt:      "https://apis.data.go.kr/1613000/AptBldgSttsService/getAptBldgStts",
  officetel:"https://apis.data.go.kr/1613000/OfctlAndDosiFormHousBldgSttsService/getOfctlAndDosiFormHousBldgStts",
  urban:    "https://apis.data.go.kr/1613000/UrbnRntHousBldgSttsService/getUrbnRntHousBldgStts",
  lodging:  "https://apis.data.go.kr/1613000/LivngHostHousBldgSttsService/getLivngHostHousBldgStts",
};

async function fetchByType({ type="apt", sido="", pageNo=1, numOfRows=10 } = {}) {
  const base = API_ENDPOINTS[type] || API_ENDPOINTS.apt;
  const params = new URLSearchParams({ serviceKey:API_KEY, pageNo, numOfRows, sido, _type:"json" });
  try {
    const res = await fetch(`${base}?${params}`);
    const data = await res.json();
    const raw = data?.response?.body?.items?.item || [];
    const items = (Array.isArray(raw) ? raw : [raw]).map(i => ({ ...i, _type: type }));
    return { items, total: data?.response?.body?.totalCount || 0 };
  } catch {
    return { items:[], total:0, error:true };
  }
}

// 주거유형 정의
const HOUSE_TYPES = [
  { key:"apt",       label:"아파트",     shortLabel:"아파트",   color:"#3B6BF5", bg:"#EEF2FF" },
  { key:"officetel", label:"오피스텔",   shortLabel:"오피스텔", color:"#7C3AED", bg:"#F3EEFF" },
  { key:"urban",     label:"도시형생활", shortLabel:"도시형",   color:"#0891B2", bg:"#E0F7FA" },
  { key:"lodging",   label:"생활숙박",   shortLabel:"생활숙박", color:"#B45309", bg:"#FFF8E1" },
];

const TYPE_MOCK = {
  officetel: [
    { id:10, houseNm:"위브더제니스 센트럴 강남", hssplyAdres:"서울특별시 강남구 역삼동 823", sido:"서울", totHouseholdCo:318, houseSecd:"민영", rcritPblancDe:"2026-06-18", przwnerPresnatnDe:"2026-07-03", mvnPrearngeYm:"2028-06", specltRceptBgnde:"2026-06-18", specltRceptEndde:"2026-06-19", gnrlRnk1CrspareaEndde:"2026-06-21", pblanc_url:"#", minPrice:65000, maxPrice:112000, competition:28.4, tag:"인기", _type:"officetel" },
    { id:11, houseNm:"힐스테이트 광교 오피스텔", hssplyAdres:"경기도 수원시 영통구 이의동", sido:"경기", totHouseholdCo:204, houseSecd:"민영", rcritPblancDe:"2026-07-05", przwnerPresnatnDe:"2026-07-20", mvnPrearngeYm:"2028-10", specltRceptBgnde:"2026-07-05", specltRceptEndde:"2026-07-06", gnrlRnk1CrspareaEndde:"2026-07-08", pblanc_url:"#", minPrice:38000, maxPrice:62000, competition:11.2, tag:"신규", _type:"officetel" },
  ],
  urban: [
    { id:20, houseNm:"더샵 광명역 도시형", hssplyAdres:"경기도 광명시 일직동 22", sido:"경기", totHouseholdCo:156, houseSecd:"민영", rcritPblancDe:"2026-06-12", przwnerPresnatnDe:"2026-06-27", mvnPrearngeYm:"2027-12", specltRceptBgnde:"2026-06-12", specltRceptEndde:"2026-06-13", gnrlRnk1CrspareaEndde:"2026-06-16", pblanc_url:"#", minPrice:28000, maxPrice:41000, competition:5.3, tag:null, _type:"urban" },
    { id:21, houseNm:"e편한세상 마포 도시형", hssplyAdres:"서울특별시 마포구 공덕동 115", sido:"서울", totHouseholdCo:89, houseSecd:"민영", rcritPblancDe:"2026-06-25", przwnerPresnatnDe:"2026-07-10", mvnPrearngeYm:"2028-03", specltRceptBgnde:"2026-06-25", specltRceptEndde:"2026-06-26", gnrlRnk1CrspareaEndde:"2026-06-28", pblanc_url:"#", minPrice:45000, maxPrice:68000, competition:19.7, tag:"마감임박", _type:"urban" },
  ],
  lodging: [
    { id:30, houseNm:"르엘 해운대 레지던스", hssplyAdres:"부산광역시 해운대구 중동 1415", sido:"부산", totHouseholdCo:412, houseSecd:"민영", rcritPblancDe:"2026-07-10", przwnerPresnatnDe:"2026-07-25", mvnPrearngeYm:"2029-01", specltRceptBgnde:"2026-07-10", specltRceptEndde:"2026-07-11", gnrlRnk1CrspareaEndde:"2026-07-13", pblanc_url:"#", minPrice:52000, maxPrice:95000, competition:7.6, tag:"신규", _type:"lodging" },
  ],
};

const MOCK_DATA = [
  { id:1, houseNm:"힐스테이트 판교역", hssplyAdres:"경기도 성남시 분당구 판교역로 166", sido:"경기", totHouseholdCo:482, houseSecd:"민영", rcritPblancDe:"2026-06-10", przwnerPresnatnDe:"2026-06-25", mvnPrearngeYm:"2028-12", specltRceptBgnde:"2026-06-10", specltRceptEndde:"2026-06-11", gnrlRnk1CrspareaEndde:"2026-06-13", pblanc_url:"#", minPrice:72000, maxPrice:135000, competition:48.2, tag:"인기", _type:"apt" },
  { id:2, houseNm:"래미안 원펜타스", hssplyAdres:"서울특별시 서초구 반포동 19", sido:"서울", totHouseholdCo:292, houseSecd:"민영", rcritPblancDe:"2026-06-15", przwnerPresnatnDe:"2026-06-30", mvnPrearngeYm:"2029-03", specltRceptBgnde:"2026-06-15", specltRceptEndde:"2026-06-16", gnrlRnk1CrspareaEndde:"2026-06-18", pblanc_url:"#", minPrice:195000, maxPrice:310000, competition:312.5, tag:"고분양가", _type:"apt" },
  { id:3, houseNm:"e편한세상 청계 센트럴포레", hssplyAdres:"경기도 광주시 오포읍 양벌리", sido:"경기", totHouseholdCo:1104, houseSecd:"민영", rcritPblancDe:"2026-05-28", przwnerPresnatnDe:"2026-06-12", mvnPrearngeYm:"2028-09", specltRceptBgnde:"2026-05-28", specltRceptEndde:"2026-05-29", gnrlRnk1CrspareaEndde:"2026-06-02", pblanc_url:"#", minPrice:38000, maxPrice:65000, competition:8.7, tag:"마감임박", _type:"apt" },
  { id:4, houseNm:"두산위브더제니스 하버시티", hssplyAdres:"부산광역시 해운대구 우동 1394", sido:"부산", totHouseholdCo:783, houseSecd:"민영", rcritPblancDe:"2026-07-01", przwnerPresnatnDe:"2026-07-16", mvnPrearngeYm:"2029-06", specltRceptBgnde:"2026-07-01", specltRceptEndde:"2026-07-02", gnrlRnk1CrspareaEndde:"2026-07-04", pblanc_url:"#", minPrice:55000, maxPrice:98000, competition:22.1, tag:"신규", _type:"apt" },
  { id:5, houseNm:"아이파크 동탄2", hssplyAdres:"경기도 화성시 동탄면 동탄역로", sido:"경기", totHouseholdCo:964, houseSecd:"민영", rcritPblancDe:"2026-06-20", przwnerPresnatnDe:"2026-07-05", mvnPrearngeYm:"2028-11", specltRceptBgnde:"2026-06-20", specltRceptEndde:"2026-06-21", gnrlRnk1CrspareaEndde:"2026-06-24", pblanc_url:"#", minPrice:42000, maxPrice:78000, competition:15.3, tag:null, _type:"apt" },
];

const SIDO_LIST = ["전체","서울","경기","인천","부산","대구","광주","대전","울산","세종","강원","충북","충남","전북","전남","경북","경남","제주"];
const QUICK_SIDO = ["서울","경기","인천","부산","대구"];
const SORT_OPTIONS = [
  { value:"recent", label:"최신순" },
  { value:"competition_high", label:"경쟁률 높은순" },
  { value:"competition_low", label:"경쟁률 낮은순" },
  { value:"price_low", label:"분양가 낮은순" },
];

function getDday(dateStr) {
  if (!dateStr) return null;
  const diff = Math.floor((new Date(dateStr) - new Date().setHours(0,0,0,0)) / 86400000);
  if (diff < 0) return null;
  return diff === 0 ? "D-Day" : `D-${diff}`;
}
function formatWon(num) {
  if (!num) return "-";
  return num >= 10000 ? `${(num/10000).toFixed(1)}억` : `${num.toLocaleString()}만`;
}

const C = { blue:"#3B6BF5", orange:"#FF6B35", bg:"#F2F4F9", card:"#fff", text:"#111", sub:"#888", muted:"#AAA" };

// ══════════════════════════════════════════════════════════════════════════════
// SVG 픽토그램 아이콘 모음
// ══════════════════════════════════════════════════════════════════════════════
const Icon = {
  // 탭바
  Home: ({size=24, color="currentColor", filled=false}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      {filled
        ? <path d="M3 10.5L12 3l9 7.5V20a1 1 0 01-1 1H15v-5h-6v5H4a1 1 0 01-1-1V10.5z" fill={color}/>
        : <><path d="M3 10.5L12 3l9 7.5V20a1 1 0 01-1 1H15v-5h-6v5H4a1 1 0 01-1-1V10.5z" stroke={color} strokeWidth="1.8" strokeLinejoin="round" fill="none"/></>
      }
    </svg>
  ),
  Calendar: ({size=24, color="currentColor", filled=false}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <rect x="3" y="5" width="18" height="16" rx="2" stroke={color} strokeWidth="1.8" fill={filled?color:"none"} fillOpacity={filled?0.15:0}/>
      <path d="M3 10h18" stroke={color} strokeWidth="1.8"/>
      <path d="M8 3v4M16 3v4" stroke={color} strokeWidth="1.8" strokeLinecap="round"/>
      {filled && <>
        <rect x="7" y="13" width="3" height="3" rx="0.5" fill={color}/>
        <rect x="14" y="13" width="3" height="3" rx="0.5" fill={color}/>
      </>}
      {!filled && <>
        <rect x="7" y="13" width="3" height="3" rx="0.5" stroke={color} strokeWidth="1.4"/>
        <rect x="14" y="13" width="3" height="3" rx="0.5" stroke={color} strokeWidth="1.4"/>
      </>}
    </svg>
  ),
  Bookmark: ({size=24, color="currentColor", filled=false}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M6 3h12a1 1 0 011 1v16.5l-7-4-7 4V4a1 1 0 011-1z"
        stroke={color} strokeWidth="1.8" strokeLinejoin="round"
        fill={filled?color:"none"}/>
    </svg>
  ),
  User: ({size=24, color="currentColor", filled=false}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="8" r="4" stroke={color} strokeWidth="1.8" fill={filled?color:"none"} fillOpacity={filled?0.2:0}/>
      <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke={color} strokeWidth="1.8" strokeLinecap="round" fill="none"/>
    </svg>
  ),
  // 카드 내부
  Pin: ({size=14, color=C.sub}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={{flexShrink:0}}>
      <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z" stroke={color} strokeWidth="1.8" fill="none"/>
      <circle cx="12" cy="9" r="2.5" stroke={color} strokeWidth="1.8"/>
    </svg>
  ),
  Search: ({size=18, color=C.muted}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <circle cx="11" cy="11" r="7" stroke={color} strokeWidth="2"/>
      <path d="M16.5 16.5L21 21" stroke={color} strokeWidth="2" strokeLinecap="round"/>
    </svg>
  ),
  Fire: ({size=12, color="#FF6B35"}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill={color}>
      <path d="M12 2c0 0-1 4-4 6 0 0 .5-2-1-4C5 7 3 10 3 13a9 9 0 0018 0c0-5-5-9-5-9s1 3-1 5c0 0-1-4-3-7z"/>
    </svg>
  ),
  Star: ({size=12, color="#E6A817"}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill={color}>
      <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
    </svg>
  ),
  Sparkle: ({size=12, color="#2E7D32"}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill={color}>
      <path d="M12 2v4M12 18v4M4.22 4.22l2.83 2.83M16.95 16.95l2.83 2.83M2 12h4M18 12h4M4.22 19.78l2.83-2.83M16.95 7.05l2.83-2.83"/>
    </svg>
  ),
  Alert: ({size=12, color:clr=C.orange}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M12 2L2 20h20L12 2z" stroke={clr} strokeWidth="2" strokeLinejoin="round"/>
      <path d="M12 9v5M12 16.5v.5" stroke={clr} strokeWidth="2" strokeLinecap="round"/>
    </svg>
  ),
  Bell: ({size=18, color=C.sub, filled=false}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M12 2a7 7 0 00-7 7v4l-2 3h18l-2-3V9a7 7 0 00-7-7z" stroke={color} strokeWidth="1.8" fill={filled?color:"none"} fillOpacity={filled?0.15:0}/>
      <path d="M10 19a2 2 0 004 0" stroke={color} strokeWidth="1.8"/>
    </svg>
  ),
  Refresh: ({size=16, color=C.blue}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M4 12a8 8 0 0114.93-4H15" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
      <path d="M20 12a8 8 0 01-14.93 4H9" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  ChevronRight: ({size=16, color=C.muted}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M9 6l6 6-6 6" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  ChevronLeft: ({size=20, color=C.text}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M15 6l-6 6 6 6" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  ChevronDown: ({size=10, color="currentColor"}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M6 9l6 6 6-6" stroke={color} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  Edit: ({size=14, color="#fff"}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7" stroke={color} strokeWidth="2" strokeLinecap="round"/>
      <path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  Info: ({size=14, color=C.sub}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="12" r="9" stroke={color} strokeWidth="1.8"/>
      <path d="M12 8v1M12 11v5" stroke={color} strokeWidth="2" strokeLinecap="round"/>
    </svg>
  ),
  Close: ({size=20, color="#999"}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M18 6L6 18M6 6l12 12" stroke={color} strokeWidth="2" strokeLinecap="round"/>
    </svg>
  ),
  Check: ({size=10, color="#fff"}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M5 12l5 5L19 7" stroke={color} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  Building: ({size=40, color=C.muted}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <rect x="3" y="3" width="11" height="18" rx="1" stroke={color} strokeWidth="1.6"/>
      <rect x="14" y="8" width="7" height="13" rx="1" stroke={color} strokeWidth="1.6"/>
      <path d="M7 7h3M7 11h3M7 15h3M17 12h1M17 16h1" stroke={color} strokeWidth="1.6" strokeLinecap="round"/>
    </svg>
  ),
  Trophy: ({size=40, color=C.muted}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M8 21h8M12 17v4" stroke={color} strokeWidth="1.6" strokeLinecap="round"/>
      <path d="M5 3H3v4a4 4 0 004 4m12-8h2v4a4 4 0 01-4 4m-2 0H7a5 5 0 01-5-5V3h10v8a5 5 0 01-5 5z" stroke={color} strokeWidth="1.6" strokeLinejoin="round"/>
    </svg>
  ),
  Wallet: ({size=18, color=C.sub}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <rect x="2" y="6" width="20" height="14" rx="2" stroke={color} strokeWidth="1.8"/>
      <path d="M2 10h20" stroke={color} strokeWidth="1.8"/>
      <circle cx="17" cy="15" r="1.5" fill={color}/>
    </svg>
  ),
  Target: ({size=18, color=C.sub}) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="12" r="9" stroke={color} strokeWidth="1.8"/>
      <circle cx="12" cy="12" r="5" stroke={color} strokeWidth="1.8"/>
      <circle cx="12" cy="12" r="1.5" fill={color}/>
    </svg>
  ),
};

// ─── 태그 픽토그램 ─────────────────────────────────────────────────────────────
function TagIcon({ tag, size=11 }) {
  if (tag === "마감임박") return <Icon.Fire size={size} />;
  if (tag === "인기") return <Icon.Star size={size} />;
  return <Icon.Sparkle size={size} />;
}

// ─── 카드 ─────────────────────────────────────────────────────────────────────
function AptCard({ item, onClick, bookmarks, onToggleBookmark }) {
  const dday = getDday(item.specltRceptBgnde || item.rcritPblancDe);
  const isUrgent = dday && dday !== "D-Day" && parseInt(dday.replace("D-","")) <= 3;
  const isBookmarked = bookmarks?.includes(item.id);
  const typeInfo = HOUSE_TYPES.find(t => t.key === (item._type || "apt")) || HOUSE_TYPES[0];
  return (
    <div onClick={() => onClick(item)}
      style={{ background:C.card, borderRadius:20, padding:"20px 18px", marginBottom:12, boxShadow:"0 2px 16px rgba(0,0,0,0.07)", cursor:"pointer", border:isUrgent?"1.5px solid "+C.orange:"1.5px solid transparent", transition:"transform 0.15s, box-shadow 0.15s" }}
      onMouseEnter={e=>{ e.currentTarget.style.transform="translateY(-2px)"; e.currentTarget.style.boxShadow="0 6px 24px rgba(0,0,0,0.12)"; }}
      onMouseLeave={e=>{ e.currentTarget.style.transform="translateY(0)"; e.currentTarget.style.boxShadow="0 2px 16px rgba(0,0,0,0.07)"; }}>
      <div style={{ display:"flex", justifyContent:"space-between", alignItems:"flex-start", marginBottom:10 }}>
        <div style={{ display:"flex", gap:6, flexWrap:"wrap" }}>
          {/* 주거유형 뱃지 */}
          <span style={{ background:typeInfo.bg, color:typeInfo.color, fontSize:11, fontWeight:700, padding:"3px 9px", borderRadius:20, display:"flex", alignItems:"center", gap:4 }}>
            <div style={{ width:5, height:5, borderRadius:"50%", background:typeInfo.color }} />
            {typeInfo.shortLabel}
          </span>
          <span style={{ background:"#F0F4FF", color:C.blue, fontSize:11, fontWeight:700, padding:"3px 9px", borderRadius:20 }}>{item.sido||item.hssplyAdres?.split(" ")[0]}</span>
          {item.houseSecd && <span style={{ background:"#F5F5F5", color:"#666", fontSize:11, fontWeight:600, padding:"3px 9px", borderRadius:20 }}>{item.houseSecd}</span>}
          {item.tag && (
            <span style={{ display:"flex", alignItems:"center", gap:3, background:item.tag==="마감임박"?"#FFF0EB":item.tag==="인기"?"#FFF3CD":"#E8F5E9", color:item.tag==="마감임박"?C.orange:item.tag==="인기"?"#E6A817":"#2E7D32", fontSize:11, fontWeight:700, padding:"3px 9px", borderRadius:20 }}>
              <TagIcon tag={item.tag} size={10}/> {item.tag}
            </span>
          )}
        </div>
        <div style={{ display:"flex", alignItems:"center", gap:6 }}>
          {dday && <span style={{ background:isUrgent?C.orange:C.blue, color:"#fff", fontSize:12, fontWeight:800, padding:"4px 10px", borderRadius:12 }}>{dday}</span>}
          {onToggleBookmark && (
            <button onClick={e=>{ e.stopPropagation(); onToggleBookmark(item.id); }}
              style={{ background:isBookmarked?"#EEF2FF":"#F5F6F8", border:"none", borderRadius:10, width:32, height:32, display:"flex", alignItems:"center", justifyContent:"center", cursor:"pointer", transition:"all 0.15s", flexShrink:0 }}>
              <Icon.Bookmark size={16} color={isBookmarked?C.blue:C.muted} filled={isBookmarked} />
            </button>
          )}
        </div>
      </div>
      <h3 style={{ fontSize:17, fontWeight:800, color:C.text, margin:"0 0 5px", letterSpacing:"-0.5px", lineHeight:1.3 }}>{item.houseNm}</h3>
      <div style={{ display:"flex", alignItems:"center", gap:4, marginBottom:14 }}>
        <Icon.Pin size={13} color={C.muted}/>
        <span style={{ fontSize:13, color:C.sub }}>{item.hssplyAdres}</span>
      </div>
      <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr 1fr", gap:8, background:"#F8F9FF", borderRadius:14, padding:"12px 10px" }}>
        <Stat label="세대수" value={item.totHouseholdCo?`${item.totHouseholdCo?.toLocaleString()}세대`:"-"} />
        <Stat label="분양가" value={item.minPrice?`${formatWon(item.minPrice)}~`:"-"} accent />
        <Stat label="경쟁률" value={item.competition?`${item.competition}:1`:"-"} hot={item.competition>50} />
      </div>
      <div style={{ marginTop:12, display:"flex", gap:6, flexWrap:"wrap" }}>
        <DateBadge label="청약시작" date={item.specltRceptBgnde||item.rcritPblancDe} />
        <DateBadge label="당첨발표" date={item.przwnerPresnatnDe} />
        <DateBadge label="입주예정" date={item.mvnPrearngeYm} />
      </div>
    </div>
  );
}
function Stat({ label, value, accent, hot }) {
  return (
    <div style={{ textAlign:"center" }}>
      <div style={{ fontSize:10, color:"#999", marginBottom:3, fontWeight:600 }}>{label}</div>
      <div style={{ fontSize:13, fontWeight:800, color:hot?C.orange:accent?C.blue:"#222" }}>{value}</div>
    </div>
  );
}
function DateBadge({ label, date }) {
  if (!date) return null;
  return (
    <div style={{ background:"#F5F5F5", borderRadius:10, padding:"5px 10px", fontSize:11 }}>
      <span style={{ color:"#999", marginRight:4 }}>{label}</span>
      <span style={{ color:"#444", fontWeight:700 }}>{date}</span>
    </div>
  );
}

// ─── 상세 모달 ────────────────────────────────────────────────────────────────
function DetailModal({ item, onClose }) {
  if (!item) return null;
  return (
    <div onClick={onClose} style={{ position:"fixed", inset:0, background:"rgba(0,0,0,0.5)", zIndex:100, display:"flex", alignItems:"flex-end", animation:"fadeIn 0.2s ease" }}>
      <div onClick={e=>e.stopPropagation()} style={{ background:"#fff", borderRadius:"24px 24px 0 0", width:"100%", maxHeight:"85vh", overflowY:"auto", padding:"28px 22px 40px", animation:"slideUp 0.3s cubic-bezier(.16,1,.3,1)" }}>
        <div style={{ width:40, height:4, background:"#E0E0E0", borderRadius:2, margin:"0 auto 20px" }} />
        <div style={{ display:"flex", justifyContent:"space-between", alignItems:"flex-start", marginBottom:6 }}>
          <span style={{ background:"#F0F4FF", color:C.blue, fontSize:12, fontWeight:700, padding:"4px 10px", borderRadius:20 }}>{item.sido||item.hssplyAdres?.split(" ")[0]}</span>
          <button onClick={onClose} style={{ background:"#F5F6F8", border:"none", borderRadius:10, width:32, height:32, display:"flex", alignItems:"center", justifyContent:"center", cursor:"pointer" }}>
            <Icon.Close size={16}/>
          </button>
        </div>
        <h2 style={{ fontSize:22, fontWeight:900, color:C.text, margin:"8px 0 6px", letterSpacing:"-0.5px" }}>{item.houseNm}</h2>
        <div style={{ display:"flex", alignItems:"center", gap:4, marginBottom:20 }}>
          <Icon.Pin size={14} color={C.muted}/>
          <span style={{ fontSize:14, color:C.sub }}>{item.hssplyAdres}</span>
        </div>
        <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:10, marginBottom:20 }}>
          {[{label:"총 세대수",value:`${item.totHouseholdCo?.toLocaleString()||"-"}세대`},{label:"주택 구분",value:item.houseSecd||"-"},{label:"최저 분양가",value:item.minPrice?formatWon(item.minPrice):"-"},{label:"최고 분양가",value:item.maxPrice?formatWon(item.maxPrice):"-"},{label:"평균 경쟁률",value:item.competition?`${item.competition}:1`:"-"},{label:"입주 예정",value:item.mvnPrearngeYm||"-"}].map(({label,value})=>(
            <div key={label} style={{ background:"#F8F9FF", borderRadius:14, padding:"14px 16px" }}>
              <div style={{ fontSize:11, color:"#999", marginBottom:4, fontWeight:600 }}>{label}</div>
              <div style={{ fontSize:16, fontWeight:800, color:"#222" }}>{value}</div>
            </div>
          ))}
        </div>
        <div style={{ borderTop:"1px solid #F0F0F0", paddingTop:16, marginBottom:20 }}>
          <div style={{ display:"flex", alignItems:"center", gap:6, marginBottom:12 }}>
            <Icon.Calendar size={15} color={C.text}/>
            <h4 style={{ fontSize:14, fontWeight:700, color:"#333", margin:0 }}>청약 일정</h4>
          </div>
          {[{label:"특별공급 접수",start:item.specltRceptBgnde,end:item.specltRceptEndde},{label:"1순위 청약",start:item.gnrlRnk1CrspareaEndde},{label:"당첨자 발표",start:item.przwnerPresnatnDe}].map(({label,start,end})=>start&&(
            <div key={label} style={{ display:"flex", justifyContent:"space-between", padding:"10px 0", borderBottom:"1px solid #F8F8F8" }}>
              <span style={{ fontSize:14, color:"#555" }}>{label}</span>
              <span style={{ fontSize:14, fontWeight:700, color:"#222" }}>{start}{end&&end!==start?` ~ ${end}`:""}</span>
            </div>
          ))}
        </div>
        <a href={item.pblanc_url||"https://www.applyhome.co.kr"} target="_blank" rel="noreferrer" style={{ display:"flex", alignItems:"center", justifyContent:"center", gap:8, background:C.blue, color:"#fff", padding:"16px", borderRadius:16, fontWeight:800, fontSize:16, textDecoration:"none" }}>
          청약홈에서 자세히 보기 <Icon.ChevronRight size={18} color="#fff"/>
        </a>
      </div>
    </div>
  );
}

// ─── 지역 바텀시트 ────────────────────────────────────────────────────────────
function SidoBottomSheet({ selected, onSelect, onClose }) {
  return (
    <div onClick={onClose} style={{ position:"fixed", inset:0, zIndex:200, background:"rgba(0,0,0,0.4)", display:"flex", alignItems:"flex-end", animation:"fadeIn 0.15s ease" }}>
      <div onClick={e=>e.stopPropagation()} style={{ background:"#fff", borderRadius:"22px 22px 0 0", width:"100%", padding:"20px 16px 36px", animation:"slideUp 0.25s cubic-bezier(.16,1,.3,1)", maxHeight:"62vh", overflowY:"auto" }}>
        <div style={{ width:36, height:4, background:"#E0E0E0", borderRadius:2, margin:"0 auto 14px" }} />
        <p style={{ textAlign:"center", fontSize:15, fontWeight:800, color:"#111", margin:"0 0 16px" }}>지역 선택</p>
        <div style={{ display:"grid", gridTemplateColumns:"repeat(3, 1fr)", gap:8 }}>
          {SIDO_LIST.map(sido => {
            const active = selected===sido;
            return (
              <button key={sido} onClick={()=>{ onSelect(sido); onClose(); }}
                style={{ background:active?C.blue:"#F5F6F8", color:active?"#fff":"#444", border:"none", borderRadius:14, padding:"13px 0", fontSize:14, fontWeight:active?800:500, cursor:"pointer", position:"relative", display:"flex", alignItems:"center", justifyContent:"center", gap:4 }}>
                {sido}
                {active && <Icon.Check size={10} color="#fff"/>}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 📅 일정 탭
// ══════════════════════════════════════════════════════════════════════════════
const WEEK_DAYS = ["일","월","화","수","목","금","토"];

function CalendarTab({ items, onSelectItem }) {
  const today = new Date();
  const [viewYear, setViewYear] = useState(today.getFullYear());
  const [viewMonth, setViewMonth] = useState(today.getMonth());
  const [selectedDate, setSelectedDate] = useState(null);

  const eventMap = {};
  items.forEach(item => {
    ["specltRceptBgnde","specltRceptEndde","gnrlRnk1CrspareaEndde","przwnerPresnatnDe"].forEach(key => {
      const d = item[key];
      if (d && d.slice(0,7) === `${viewYear}-${String(viewMonth+1).padStart(2,"0")}`) {
        if (!eventMap[d]) eventMap[d] = [];
        eventMap[d].push({ ...item, eventType: key });
      }
    });
  });

  const EVENT_COLOR = { specltRceptBgnde:C.blue, specltRceptEndde:"#8B5CF6", gnrlRnk1CrspareaEndde:"#F59E0B", przwnerPresnatnDe:"#10B981" };
  const EVENT_LABEL = { specltRceptBgnde:"특공시작", specltRceptEndde:"특공마감", gnrlRnk1CrspareaEndde:"1순위", przwnerPresnatnDe:"당첨발표" };

  const firstDay = new Date(viewYear, viewMonth, 1).getDay();
  const daysInMonth = new Date(viewYear, viewMonth+1, 0).getDate();
  const cells = [];
  for (let i=0; i<firstDay; i++) cells.push(null);
  for (let d=1; d<=daysInMonth; d++) cells.push(d);

  const fmtDate = d => `${viewYear}-${String(viewMonth+1).padStart(2,"0")}-${String(d).padStart(2,"0")}`;
  const isToday = d => d && viewYear===today.getFullYear() && viewMonth===today.getMonth() && d===today.getDate();
  const selectedEvents = selectedDate ? (eventMap[selectedDate]||[]) : [];
  const monthItems = items.filter(item => {
    const d = item.specltRceptBgnde || item.rcritPblancDe;
    return d && d.startsWith(`${viewYear}-${String(viewMonth+1).padStart(2,"0")}`);
  });

  return (
    <div style={{ flex:1, overflowY:"auto", background:C.bg }}>
      <div style={{ background:"#fff", padding:"20px 20px 16px", boxShadow:"0 1px 8px rgba(0,0,0,0.05)" }}>
        <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:16 }}>
          <button onClick={()=>{ if(viewMonth===0){setViewMonth(11);setViewYear(v=>v-1);}else setViewMonth(m=>m-1); setSelectedDate(null); }}
            style={{ background:"#F5F6F8", border:"none", borderRadius:10, width:36, height:36, display:"flex", alignItems:"center", justifyContent:"center", cursor:"pointer" }}>
            <Icon.ChevronLeft size={18}/>
          </button>
          <span style={{ fontSize:18, fontWeight:800, color:C.text, letterSpacing:"-0.5px" }}>{viewYear}년 {viewMonth+1}월</span>
          <button onClick={()=>{ if(viewMonth===11){setViewMonth(0);setViewYear(v=>v+1);}else setViewMonth(m=>m+1); setSelectedDate(null); }}
            style={{ background:"#F5F6F8", border:"none", borderRadius:10, width:36, height:36, display:"flex", alignItems:"center", justifyContent:"center", cursor:"pointer" }}>
            <svg width={18} height={18} viewBox="0 0 24 24" fill="none"><path d="M9 6l6 6-6 6" stroke={C.text} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
          </button>
        </div>
        <div style={{ display:"grid", gridTemplateColumns:"repeat(7,1fr)", marginBottom:6 }}>
          {WEEK_DAYS.map((d,i)=>(
            <div key={d} style={{ textAlign:"center", fontSize:11, fontWeight:700, color:i===0?"#F05":(i===6?C.blue:C.muted), paddingBottom:6 }}>{d}</div>
          ))}
        </div>
        <div style={{ display:"grid", gridTemplateColumns:"repeat(7,1fr)", gap:"2px 0" }}>
          {cells.map((d,i) => {
            if (!d) return <div key={`e${i}`} />;
            const dateStr = fmtDate(d);
            const dots = eventMap[dateStr] ? [...new Set(eventMap[dateStr].map(e=>e.eventType))] : [];
            const isSelected = selectedDate===dateStr;
            const isTod = isToday(d);
            return (
              <div key={dateStr} onClick={()=>setSelectedDate(isSelected?null:dateStr)}
                style={{ display:"flex", flexDirection:"column", alignItems:"center", padding:"5px 2px", borderRadius:10, background:isSelected?C.blue:"transparent", cursor:dots.length?"pointer":"default" }}>
                <span style={{ fontSize:13, fontWeight:isTod||isSelected?800:400, color:isSelected?"#fff":isTod?C.blue:(i%7===0?"#F05":i%7===6?C.blue:C.text), width:28, height:28, display:"flex", alignItems:"center", justifyContent:"center", borderRadius:"50%", background:isTod&&!isSelected?"#EEF2FF":"transparent" }}>{d}</span>
                <div style={{ display:"flex", gap:2, marginTop:2, height:5 }}>
                  {dots.slice(0,3).map(t=>(
                    <div key={t} style={{ width:4, height:4, borderRadius:"50%", background:isSelected?"rgba(255,255,255,0.8)":EVENT_COLOR[t] }} />
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {selectedDate && selectedEvents.length > 0 && (
        <div style={{ padding:"16px 16px 0" }}>
          <p style={{ fontSize:13, color:C.sub, fontWeight:600, marginBottom:10 }}>{selectedDate.slice(5).replace("-","월 ")}일 일정</p>
          {selectedEvents.map((ev,i)=>(
            <div key={i} onClick={()=>onSelectItem(ev)}
              style={{ background:"#fff", borderRadius:16, padding:"14px 16px", marginBottom:10, display:"flex", alignItems:"center", gap:12, cursor:"pointer", boxShadow:"0 2px 10px rgba(0,0,0,0.06)" }}>
              <div style={{ width:4, height:44, borderRadius:4, background:EVENT_COLOR[ev.eventType], flexShrink:0 }} />
              <div style={{ flex:1 }}>
                <div style={{ fontSize:11, fontWeight:700, color:EVENT_COLOR[ev.eventType], marginBottom:3 }}>{EVENT_LABEL[ev.eventType]}</div>
                <div style={{ fontSize:14, fontWeight:800, color:C.text }}>{ev.houseNm}</div>
                <div style={{ fontSize:12, color:C.sub, marginTop:2 }}>{ev.sido}</div>
              </div>
              <Icon.ChevronRight size={16}/>
            </div>
          ))}
        </div>
      )}

      <div style={{ padding:"20px 16px 100px" }}>
        <p style={{ fontSize:14, fontWeight:800, color:C.text, marginBottom:12 }}>
          {viewMonth+1}월 청약 일정 <span style={{ color:C.blue }}>({monthItems.length}건)</span>
        </p>
        {monthItems.length === 0
          ? <div style={{ textAlign:"center", padding:"40px 0", color:C.muted, fontSize:14 }}>이달 예정 청약이 없습니다</div>
          : monthItems.map(item => {
            const dday = getDday(item.specltRceptBgnde||item.rcritPblancDe);
            return (
              <div key={item.id} onClick={()=>onSelectItem(item)}
                style={{ background:"#fff", borderRadius:16, padding:"16px", marginBottom:10, display:"flex", justifyContent:"space-between", alignItems:"center", cursor:"pointer", boxShadow:"0 2px 10px rgba(0,0,0,0.05)" }}>
                <div>
                  <div style={{ fontSize:14, fontWeight:800, color:C.text, marginBottom:4 }}>{item.houseNm}</div>
                  <div style={{ display:"flex", alignItems:"center", gap:4, marginBottom:6 }}>
                    <Icon.Pin size={12} color={C.muted}/>
                    <span style={{ fontSize:12, color:C.sub }}>{item.hssplyAdres}</span>
                  </div>
                  <div style={{ display:"flex", gap:6 }}>
                    <span style={{ background:"#F0F4FF", color:C.blue, fontSize:11, fontWeight:700, padding:"2px 8px", borderRadius:10 }}>{item.specltRceptBgnde||item.rcritPblancDe}</span>
                    <span style={{ background:"#F5F5F5", color:"#666", fontSize:11, fontWeight:600, padding:"2px 8px", borderRadius:10 }}>{formatWon(item.minPrice)}~</span>
                  </div>
                </div>
                {dday && <span style={{ background:C.blue, color:"#fff", fontSize:12, fontWeight:800, padding:"5px 10px", borderRadius:10 }}>{dday}</span>}
              </div>
            );
          })}
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 🔖 찜한 곳 탭
// ══════════════════════════════════════════════════════════════════════════════
function BookmarkTab({ items, bookmarks, onToggleBookmark, onSelectItem }) {
  const bookmarked = items.filter(item => bookmarks.includes(item.id));
  const [filterType, setFilterType] = useState("all");
  const filtered = bookmarked.filter(item => {
    if (filterType==="upcoming") { const d=item.specltRceptBgnde||item.rcritPblancDe; return d&&new Date(d)>=new Date(); }
    if (filterType==="announced") return item.przwnerPresnatnDe&&new Date(item.przwnerPresnatnDe)>=new Date();
    return true;
  });

  return (
    <div style={{ flex:1, overflowY:"auto", background:C.bg }}>
      <div style={{ background:"#fff", padding:"20px 20px 14px", boxShadow:"0 1px 8px rgba(0,0,0,0.05)" }}>
        <div style={{ display:"flex", alignItems:"center", gap:8, marginBottom:14 }}>
          <Icon.Bookmark size={20} color={C.text} filled/>
          <h2 style={{ fontSize:20, fontWeight:900, color:C.text, margin:0 }}>찜한 청약</h2>
        </div>
        <div style={{ display:"flex", gap:8 }}>
          {[{v:"all",l:"전체"},{v:"upcoming",l:"청약 예정"},{v:"announced",l:"발표 예정"}].map(({v,l})=>(
            <button key={v} onClick={()=>setFilterType(v)}
              style={{ background:filterType===v?C.blue:"#F5F6F8", color:filterType===v?"#fff":"#666", border:"none", borderRadius:20, padding:"7px 14px", fontSize:13, fontWeight:filterType===v?700:500, cursor:"pointer" }}>
              {l}
            </button>
          ))}
        </div>
      </div>

      <div style={{ padding:"16px 16px 100px" }}>
        {bookmarked.length === 0 ? (
          <div style={{ textAlign:"center", padding:"80px 0 40px" }}>
            <div style={{ display:"flex", justifyContent:"center", marginBottom:16, opacity:0.3 }}><Icon.Bookmark size={52} color={C.muted}/></div>
            <p style={{ fontSize:16, fontWeight:700, color:C.text, marginBottom:8 }}>찜한 청약이 없어요</p>
            <p style={{ fontSize:13, color:C.sub, lineHeight:1.6 }}>청약 목록에서 북마크 아이콘을 눌러<br/>관심 있는 청약을 저장해보세요</p>
          </div>
        ) : filtered.length === 0 ? (
          <div style={{ textAlign:"center", padding:"60px 0", color:C.muted, fontSize:14 }}>해당 조건의 찜한 청약이 없습니다</div>
        ) : filtered.map(item => (
          <BookmarkCard key={item.id} item={item} onSelect={onSelectItem} onRemove={()=>onToggleBookmark(item.id)} />
        ))}
        {bookmarked.length > 0 && (
          <div style={{ marginTop:8, padding:"14px 16px", background:"#fff", borderRadius:16, display:"flex", justifyContent:"space-between", alignItems:"center" }}>
            <span style={{ fontSize:13, color:C.sub }}>총 <strong style={{ color:C.blue }}>{bookmarked.length}개</strong> 저장됨</span>
            <div style={{ display:"flex", alignItems:"center", gap:4 }}>
              <Icon.Bell size={13} color={C.muted}/>
              <span style={{ fontSize:12, color:C.muted }}>알림을 설정하세요</span>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

function BookmarkCard({ item, onSelect, onRemove }) {
  const dday = getDday(item.specltRceptBgnde || item.rcritPblancDe);
  const isUrgent = dday && dday !== "D-Day" && parseInt(dday.replace("D-","")) <= 3;
  return (
    <div style={{ background:"#fff", borderRadius:18, marginBottom:12, overflow:"hidden", boxShadow:"0 2px 12px rgba(0,0,0,0.06)" }}>
      <div style={{ height:4, background:isUrgent?`linear-gradient(90deg,${C.orange},#FF8C5A)`:`linear-gradient(90deg,${C.blue},#5B8AF8)` }} />
      <div style={{ padding:"16px" }}>
        <div style={{ display:"flex", justifyContent:"space-between", alignItems:"flex-start", marginBottom:8 }}>
          <div style={{ flex:1 }}>
            <div style={{ display:"flex", gap:6, marginBottom:6, flexWrap:"wrap" }}>
              <span style={{ background:"#F0F4FF", color:C.blue, fontSize:11, fontWeight:700, padding:"2px 8px", borderRadius:10 }}>{item.sido}</span>
              {item.tag && (
                <span style={{ display:"flex", alignItems:"center", gap:3, background:item.tag==="마감임박"?"#FFF0EB":"#FFF3CD", color:item.tag==="마감임박"?C.orange:"#E6A817", fontSize:11, fontWeight:700, padding:"2px 8px", borderRadius:10 }}>
                  <TagIcon tag={item.tag} size={9}/> {item.tag}
                </span>
              )}
            </div>
            <h3 style={{ fontSize:16, fontWeight:800, color:C.text, margin:0 }}>{item.houseNm}</h3>
            <div style={{ display:"flex", alignItems:"center", gap:4, marginTop:4 }}>
              <Icon.Pin size={12} color={C.muted}/>
              <span style={{ fontSize:12, color:C.sub }}>{item.hssplyAdres}</span>
            </div>
          </div>
          {dday && <span style={{ background:isUrgent?C.orange:C.blue, color:"#fff", fontSize:12, fontWeight:800, padding:"5px 10px", borderRadius:10, marginLeft:8, flexShrink:0 }}>{dday}</span>}
        </div>
        <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr 1fr", gap:6, background:"#F8F9FF", borderRadius:12, padding:"10px", marginBottom:12 }}>
          <Stat label="세대수" value={item.totHouseholdCo?`${item.totHouseholdCo?.toLocaleString()}세대`:"-"} />
          <Stat label="분양가" value={item.minPrice?`${formatWon(item.minPrice)}~`:"-"} accent />
          <Stat label="경쟁률" value={item.competition?`${item.competition}:1`:"-"} hot={item.competition>50} />
        </div>
        <div style={{ display:"flex", alignItems:"center", gap:0, marginBottom:14, overflowX:"auto" }}>
          {[{label:"청약시작",date:item.specltRceptBgnde||item.rcritPblancDe,color:C.blue},{label:"당첨발표",date:item.przwnerPresnatnDe,color:"#10B981"},{label:"입주예정",date:item.mvnPrearngeYm,color:"#8B5CF6"}].map(({label,date,color},i)=>(
            <div key={label} style={{ display:"flex", alignItems:"center" }}>
              {i>0 && <div style={{ width:18, height:1, background:"#E0E0E0" }} />}
              <div style={{ textAlign:"center", flexShrink:0 }}>
                <div style={{ fontSize:9, color, fontWeight:700, marginBottom:2 }}>{label}</div>
                <div style={{ fontSize:10, color:"#555", fontWeight:600, whiteSpace:"nowrap" }}>{date||"-"}</div>
              </div>
            </div>
          ))}
        </div>
        <div style={{ display:"flex", gap:8 }}>
          <button onClick={()=>onSelect(item)}
            style={{ flex:1, background:C.blue, color:"#fff", border:"none", borderRadius:12, padding:"10px", fontSize:13, fontWeight:700, cursor:"pointer", display:"flex", alignItems:"center", justifyContent:"center", gap:6 }}>
            자세히 보기 <Icon.ChevronRight size={14} color="#fff"/>
          </button>
          <button onClick={onRemove}
            style={{ background:"#FFF0EB", color:C.orange, border:"none", borderRadius:12, padding:"10px 14px", fontSize:13, fontWeight:700, cursor:"pointer", display:"flex", alignItems:"center", gap:5 }}>
            <Icon.Bookmark size={14} color={C.orange} filled/> 해제
          </button>
        </div>
      </div>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 👤 마이페이지 탭
// ══════════════════════════════════════════════════════════════════════════════
const DEFAULT_PROFILE = { name:"청약 메이트 유저", area:"서울", budget:80000, householdType:"일반", hasHouse:false };
const BUDGET_OPTIONS = [30000,50000,80000,100000,150000,200000];
const AREA_OPTIONS = ["전체","서울","경기","인천","부산","대구","광주","대전"];

function MyPageTab({ bookmarks, items }) {
  const [profile, setProfile] = useState(DEFAULT_PROFILE);
  const [editing, setEditing] = useState(false);
  const [draft, setDraft] = useState(profile);
  const [notifStates, setNotifStates] = useState({ start:true, announce:true, deadline:true });

  const recommended = items.filter(item =>
    (!item.minPrice||item.minPrice<=profile.budget) &&
    (profile.area==="전체"||(item.sido||"").includes(profile.area))
  );

  const stats = [
    { label:"찜한 청약", value:bookmarks.length, icon:<Icon.Bookmark size={20} color="#fff"/>, color:C.blue },
    { label:"추천 청약", value:recommended.length, icon:<Icon.Star size={20} color="#fff"/>, color:"#F59E0B" },
    { label:"마감 임박", value:items.filter(i=>{ const d=getDday(i.specltRceptEndde||i.specltRceptBgnde); return d&&d!=="D-Day"&&parseInt(d.replace("D-",""))<=7; }).length, icon:<Icon.Alert size={20} color="#fff"/>, color:C.orange },
  ];

  const notifItems = [
    { key:"start", label:"청약 시작 알림", sub:"청약 접수 D-3일 전 알림" },
    { key:"announce", label:"당첨 발표 알림", sub:"당첨자 발표일 당일 알림" },
    { key:"deadline", label:"마감 임박 알림", sub:"접수 마감 하루 전 알림" },
  ];

  const appInfoRows = [
    { label:"버전", value:"1.0.0 (베타)" },
    { label:"데이터 출처", value:"공공데이터포털" },
    { label:"업데이트", value:"매일 오전 6시" },
    { label:"문의/피드백", value:"이메일 보내기" },
  ];

  return (
    <div style={{ flex:1, overflowY:"auto", background:C.bg }}>
      {/* 프로필 헤더 */}
      <div style={{ background:`linear-gradient(135deg,${C.blue},#5B8AF8)`, padding:"32px 20px 28px" }}>
        <div style={{ display:"flex", alignItems:"center", gap:16, marginBottom:20 }}>
          <div style={{ width:60, height:60, borderRadius:"50%", background:"rgba(255,255,255,0.2)", border:"2px solid rgba(255,255,255,0.4)", display:"flex", alignItems:"center", justifyContent:"center" }}>
            <Icon.User size={28} color="#fff" filled/>
          </div>
          <div style={{ flex:1 }}>
            <p style={{ color:"rgba(255,255,255,0.75)", fontSize:12, margin:"0 0 4px", fontWeight:500 }}>청약 메이트</p>
            <h2 style={{ color:"#fff", fontSize:20, fontWeight:900, margin:0, letterSpacing:"-0.5px" }}>{profile.name}</h2>
            <div style={{ display:"flex", alignItems:"center", gap:4, marginTop:4 }}>
              <Icon.Pin size={12} color="rgba(255,255,255,0.7)"/>
              <p style={{ color:"rgba(255,255,255,0.7)", fontSize:12, margin:0 }}>
                {profile.area} · {formatWon(profile.budget)} 이하
              </p>
            </div>
          </div>
          <button onClick={()=>{ setDraft(profile); setEditing(true); }}
            style={{ background:"rgba(255,255,255,0.2)", border:"1px solid rgba(255,255,255,0.35)", color:"#fff", borderRadius:10, padding:"7px 10px", fontSize:12, fontWeight:700, cursor:"pointer", display:"flex", alignItems:"center", gap:5 }}>
            <Icon.Edit size={12}/> 편집
          </button>
        </div>
        <div style={{ display:"grid", gridTemplateColumns:"repeat(3,1fr)", gap:10 }}>
          {stats.map(({label,value,icon,color})=>(
            <div key={label} style={{ background:"rgba(255,255,255,0.18)", borderRadius:14, padding:"12px 10px", textAlign:"center" }}>
              <div style={{ display:"flex", justifyContent:"center", marginBottom:4 }}>{icon}</div>
              <div style={{ fontSize:22, fontWeight:900, color:"#fff" }}>{value}</div>
              <div style={{ fontSize:10, color:"rgba(255,255,255,0.8)", fontWeight:600 }}>{label}</div>
            </div>
          ))}
        </div>
      </div>

      <div style={{ padding:"16px 16px 100px" }}>
        {/* 내 청약 조건 */}
        <Section title="내 청약 조건" icon={<Icon.Target size={15} color={C.blue}/>}>
          <CondRow label="관심 지역" value={profile.area} />
          <CondRow label="예산 한도" value={formatWon(profile.budget)+" 이하"} />
          <CondRow label="세대 유형" value={profile.householdType} />
          <CondRow label="주택 보유 여부" value={profile.hasHouse?"보유":"무주택"} last />
        </Section>

        {/* 추천 청약 */}
        <Section title={`맞춤 추천 (${recommended.length}건)`} icon={<Icon.Star size={15} color="#F59E0B"/>}>
          {recommended.length === 0
            ? <div style={{ padding:"20px 0", textAlign:"center", color:C.muted, fontSize:13 }}>조건에 맞는 청약이 없습니다</div>
            : recommended.slice(0,3).map(item=>(
              <div key={item.id} style={{ display:"flex", justifyContent:"space-between", alignItems:"center", padding:"12px 0", borderBottom:"1px solid #F5F5F5" }}>
                <div>
                  <div style={{ fontSize:14, fontWeight:700, color:C.text }}>{item.houseNm}</div>
                  <div style={{ display:"flex", alignItems:"center", gap:4, marginTop:2 }}>
                    <Icon.Pin size={11} color={C.muted}/>
                    <span style={{ fontSize:12, color:C.sub }}>{item.sido} · {formatWon(item.minPrice)}~</span>
                  </div>
                </div>
                {getDday(item.specltRceptBgnde) && (
                  <span style={{ background:"#F0F4FF", color:C.blue, fontSize:12, fontWeight:700, padding:"4px 10px", borderRadius:10 }}>
                    {getDday(item.specltRceptBgnde)}
                  </span>
                )}
              </div>
            ))
          }
        </Section>

        {/* 알림 설정 */}
        <Section title="알림 설정" icon={<Icon.Bell size={15} color={C.text}/>}>
          {notifItems.map(({key,label,sub},i,arr)=>(
            <div key={key} style={{ display:"flex", justifyContent:"space-between", alignItems:"center", padding:"13px 0", borderBottom:i<arr.length-1?"1px solid #F5F5F5":"none" }}>
              <div>
                <div style={{ fontSize:14, fontWeight:600, color:C.text }}>{label}</div>
                <div style={{ fontSize:11, color:C.sub, marginTop:2 }}>{sub}</div>
              </div>
              <Toggle on={notifStates[key]} onChange={v=>setNotifStates(s=>({...s,[key]:v}))} />
            </div>
          ))}
        </Section>

        {/* 앱 정보 */}
        <Section title="앱 정보" icon={<Icon.Info size={15} color={C.sub}/>}>
          {appInfoRows.map(({label,value},i,arr)=>(
            <div key={label} style={{ display:"flex", justifyContent:"space-between", alignItems:"center", padding:"12px 0", borderBottom:i<arr.length-1?"1px solid #F5F5F5":"none" }}>
              <span style={{ fontSize:14, color:"#555" }}>{label}</span>
              <span style={{ fontSize:14, fontWeight:600, color:C.sub }}>{value}</span>
            </div>
          ))}
        </Section>
      </div>

      {/* 프로필 편집 모달 */}
      {editing && (
        <div onClick={()=>setEditing(false)} style={{ position:"fixed", inset:0, background:"rgba(0,0,0,0.5)", zIndex:100, display:"flex", alignItems:"flex-end", animation:"fadeIn 0.2s ease" }}>
          <div onClick={e=>e.stopPropagation()} style={{ background:"#fff", borderRadius:"24px 24px 0 0", width:"100%", padding:"24px 20px 40px", animation:"slideUp 0.3s cubic-bezier(.16,1,.3,1)", maxHeight:"85vh", overflowY:"auto" }}>
            <div style={{ width:40, height:4, background:"#E0E0E0", borderRadius:2, margin:"0 auto 20px" }} />
            <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:20 }}>
              <h3 style={{ fontSize:18, fontWeight:900, color:C.text, margin:0 }}>내 조건 편집</h3>
              <button onClick={()=>setEditing(false)} style={{ background:"#F5F6F8", border:"none", borderRadius:10, width:32, height:32, display:"flex", alignItems:"center", justifyContent:"center", cursor:"pointer" }}>
                <Icon.Close size={16}/>
              </button>
            </div>
            <label style={{ display:"block", marginBottom:16 }}>
              <span style={{ fontSize:12, fontWeight:700, color:C.sub, display:"block", marginBottom:6 }}>닉네임</span>
              <input value={draft.name} onChange={e=>setDraft(d=>({...d,name:e.target.value}))}
                style={{ width:"100%", background:"#F5F6F8", border:"none", borderRadius:12, padding:"12px 14px", fontSize:14, outline:"none", color:C.text }} />
            </label>
            <label style={{ display:"block", marginBottom:16 }}>
              <span style={{ fontSize:12, fontWeight:700, color:C.sub, display:"block", marginBottom:6 }}>관심 지역</span>
              <select value={draft.area} onChange={e=>setDraft(d=>({...d,area:e.target.value}))}
                style={{ width:"100%", background:"#F5F6F8", border:"none", borderRadius:12, padding:"12px 14px", fontSize:14, outline:"none", color:C.text, cursor:"pointer" }}>
                {AREA_OPTIONS.map(o=><option key={o} value={o}>{o}</option>)}
              </select>
            </label>
            <div style={{ marginBottom:16 }}>
              <span style={{ fontSize:12, fontWeight:700, color:C.sub, display:"block", marginBottom:6 }}>예산 한도 ({formatWon(draft.budget)})</span>
              <div style={{ display:"grid", gridTemplateColumns:"repeat(3,1fr)", gap:8 }}>
                {BUDGET_OPTIONS.map(b=>(
                  <button key={b} onClick={()=>setDraft(d=>({...d,budget:b}))}
                    style={{ background:draft.budget===b?C.blue:"#F5F6F8", color:draft.budget===b?"#fff":"#444", border:"none", borderRadius:12, padding:"10px 0", fontSize:13, fontWeight:700, cursor:"pointer" }}>
                    {formatWon(b)}
                  </button>
                ))}
              </div>
            </div>
            <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:24 }}>
              <span style={{ fontSize:14, fontWeight:600, color:C.text }}>무주택 세대주</span>
              <Toggle on={!draft.hasHouse} onChange={v=>setDraft(d=>({...d,hasHouse:!v}))} />
            </div>
            <button onClick={()=>{ setProfile(draft); setEditing(false); }}
              style={{ width:"100%", background:C.blue, color:"#fff", border:"none", borderRadius:16, padding:"16px", fontSize:16, fontWeight:800, cursor:"pointer" }}>
              저장하기
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

function Section({ title, icon, children }) {
  return (
    <div style={{ background:"#fff", borderRadius:18, padding:"16px", marginBottom:12, boxShadow:"0 1px 8px rgba(0,0,0,0.05)" }}>
      <div style={{ display:"flex", alignItems:"center", gap:7, marginBottom:12 }}>
        {icon}
        <p style={{ fontSize:13, fontWeight:800, color:C.text, margin:0 }}>{title}</p>
      </div>
      {children}
    </div>
  );
}
function CondRow({ label, value, last }) {
  return (
    <div style={{ display:"flex", justifyContent:"space-between", padding:"10px 0", borderBottom:last?"none":"1px solid #F5F5F5" }}>
      <span style={{ fontSize:14, color:"#555" }}>{label}</span>
      <span style={{ fontSize:14, fontWeight:700, color:C.text }}>{value}</span>
    </div>
  );
}
function Toggle({ on, onChange }) {
  return (
    <div onClick={()=>onChange(!on)} style={{ width:46, height:26, borderRadius:13, background:on?C.blue:"#DDD", position:"relative", cursor:"pointer", transition:"background 0.2s", flexShrink:0 }}>
      <div style={{ width:20, height:20, borderRadius:"50%", background:"#fff", position:"absolute", top:3, left:on?23:3, transition:"left 0.2s", boxShadow:"0 1px 4px rgba(0,0,0,0.2)" }} />
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// 🏠 메인 앱
// ══════════════════════════════════════════════════════════════════════════════
export default function CheongYakApp() {
  const [items, setItems] = useState(MOCK_DATA);
  const [loading, setLoading] = useState(false);
  const [selectedSido, setSelectedSido] = useState("전체");
  const [sortBy, setSortBy] = useState("recent");
  const [searchText, setSearchText] = useState("");
  const [selectedItem, setSelectedItem] = useState(null);
  const [activeTab, setActiveTab] = useState("list");
  const [usingMock, setUsingMock] = useState(true);
  const [showSidoSheet, setShowSidoSheet] = useState(false);
  const [bookmarks, setBookmarks] = useState([1,3]);

  const [pullY, setPullY] = useState(0);
  const [isPulling, setIsPulling] = useState(false);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const touchStartY = useRef(0);
  const scrollRef = useRef(null);
  const PULL_THRESHOLD = 68;
  const [selectedTypes, setSelectedTypes] = useState(["apt","officetel","urban","lodging"]);

  const toggleType = (key) => {
    setSelectedTypes(prev =>
      prev.includes(key)
        ? prev.length > 1 ? prev.filter(t => t !== key) : prev
        : [...prev, key]
    );
  };

  const loadData = useCallback(async () => {
    if (API_KEY === "YOUR_API_KEY_HERE") {
      const otherMock = Object.values(TYPE_MOCK).flat();
      setItems([...MOCK_DATA, ...otherMock]);
      setUsingMock(true);
      return;
    }
    setLoading(true); setUsingMock(false);
    const sido = selectedSido === "전체" ? "" : selectedSido;
    const results = await Promise.all(HOUSE_TYPES.map(t => fetchByType({ type:t.key, sido })));
    const all = results.flatMap(r => r.items);
    if (all.length === 0) {
      setItems([...MOCK_DATA, ...Object.values(TYPE_MOCK).flat()]);
      setUsingMock(true);
    } else {
      setItems(all);
    }
    setLoading(false);
  }, [selectedSido]);

  useEffect(() => { loadData(); }, [loadData]);

  const toggleBookmark = id => setBookmarks(prev => prev.includes(id) ? prev.filter(b=>b!==id) : [...prev,id]);

  const onTouchStart = e => {
    if (scrollRef.current?.scrollTop===0) { touchStartY.current=e.touches[0].clientY; setIsPulling(true); }
  };
  const onTouchMove = e => {
    if (!isPulling) return;
    const dy = e.touches[0].clientY - touchStartY.current;
    if (dy>0 && scrollRef.current?.scrollTop===0) { e.preventDefault(); setPullY(Math.min(dy*0.48, PULL_THRESHOLD+22)); }
  };
  const onTouchEnd = async () => {
    if (pullY>=PULL_THRESHOLD) { setIsRefreshing(true); setPullY(0); setIsPulling(false); await loadData(); setIsRefreshing(false); }
    else { setPullY(0); setIsPulling(false); }
  };

  const filtered = items
    .filter(item => {
      const sidoMatch = selectedSido==="전체"||(item.sido||item.hssplyAdres||"").includes(selectedSido);
      const searchMatch = !searchText||(item.houseNm||"").includes(searchText)||(item.hssplyAdres||"").includes(searchText);
      const typeMatch = selectedTypes.includes(item._type || "apt");
      return sidoMatch && searchMatch && typeMatch;
    })
    .sort((a,b) => {
      if (sortBy==="competition_high") return (b.competition||0)-(a.competition||0);
      if (sortBy==="competition_low") return (a.competition||0)-(b.competition||0);
      if (sortBy==="price_low") return (a.minPrice||0)-(b.minPrice||0);
      return new Date(b.rcritPblancDe||0)-new Date(a.rcritPblancDe||0);
    });

  const pullProgress = Math.min(pullY/PULL_THRESHOLD,1);
  const pullReady = pullY>=PULL_THRESHOLD;

  const TABS = [
    { key:"list",     label:"청약목록", icon:(active)=><Icon.Home     size={24} color={active?C.blue:C.muted} filled={active}/> },
    { key:"calendar", label:"일정",     icon:(active)=><Icon.Calendar  size={24} color={active?C.blue:C.muted} filled={active}/> },
    { key:"bookmark", label:"찜",      icon:(active)=><Icon.Bookmark  size={24} color={active?C.blue:C.muted} filled={active}/>, badge:bookmarks.length },
    { key:"mypage",   label:"마이페이지",icon:(active)=><Icon.User     size={24} color={active?C.blue:C.muted} filled={active}/> },
  ];

  return (
    <div style={{ maxWidth:430, margin:"0 auto", height:"100vh", background:C.bg, fontFamily:"'Apple SD Gothic Neo','Noto Sans KR',sans-serif", display:"flex", flexDirection:"column", overflow:"hidden" }}>
      <style>{`
        @keyframes fadeIn{from{opacity:0}to{opacity:1}}
        @keyframes slideUp{from{transform:translateY(100%)}to{transform:translateY(0)}}
        @keyframes spin{to{transform:rotate(360deg)}}
        *{box-sizing:border-box;-webkit-tap-highlight-color:transparent;}
        ::-webkit-scrollbar{width:0;}
      `}</style>

      {/* 청약목록 헤더 */}
      {activeTab==="list" && (
        <div style={{ background:"#fff", padding:"52px 20px 14px", flexShrink:0, boxShadow:"0 1px 12px rgba(0,0,0,0.06)", zIndex:50 }}>
          <div style={{ display:"flex", alignItems:"center", gap:8, marginBottom:2 }}>
            <Icon.Home size={22} color={C.blue} filled/>
            <h1 style={{ fontSize:22, fontWeight:900, color:C.text, margin:0, letterSpacing:"-0.8px" }}>청약 메이트</h1>
          </div>
          <p style={{ fontSize:12, color:C.muted, margin:"0 0 14px", fontWeight:500 }}>
            {usingMock?"⚠️ 데모 데이터 · API 키를 설정해주세요":`${filtered.length}개 공고 확인됨`}
          </p>
          <div style={{ position:"relative", marginBottom:12 }}>
            <span style={{ position:"absolute", left:14, top:"50%", transform:"translateY(-50%)" }}><Icon.Search size={16}/></span>
            <input value={searchText} onChange={e=>setSearchText(e.target.value)} placeholder="단지명, 지역 검색"
              style={{ width:"100%", background:"#F5F6F8", border:"none", borderRadius:14, padding:"12px 14px 12px 40px", fontSize:14, outline:"none", color:"#222" }} />
          </div>
          <div style={{ display:"flex", gap:8, alignItems:"center" }}>
            <button onClick={()=>setShowSidoSheet(true)}
              style={{ flexShrink:0, display:"flex", alignItems:"center", gap:5, background:selectedSido==="전체"?C.blue:"#fff", color:selectedSido==="전체"?"#fff":C.blue, border:selectedSido==="전체"?"none":"1.5px solid "+C.blue, borderRadius:20, padding:"7px 13px", fontSize:13, fontWeight:700, cursor:"pointer" }}>
              <span>{selectedSido==="전체"?"전체":selectedSido}</span>
              <Icon.ChevronDown size={9} color={selectedSido==="전체"?"#fff":C.blue}/>
            </button>
            <div style={{ display:"flex", gap:8, overflowX:"auto", paddingBottom:2 }}>
              {QUICK_SIDO.filter(s=>s!==selectedSido).map(sido=>(
                <button key={sido} onClick={()=>setSelectedSido(sido)}
                  style={{ flexShrink:0, background:"#F5F6F8", color:"#666", border:"none", borderRadius:20, padding:"7px 14px", fontSize:13, fontWeight:500, cursor:"pointer" }}>
                  {sido}
                </button>
              ))}
            </div>
          </div>

          {/* 주거유형 필터 */}
          <div style={{ display:"flex", gap:7, marginTop:10, paddingBottom:2, overflowX:"auto" }}>
            {HOUSE_TYPES.map(({ key, shortLabel, color, bg }) => {
              const active = selectedTypes.includes(key);
              return (
                <button key={key} onClick={() => toggleType(key)}
                  style={{
                    flexShrink:0, display:"flex", alignItems:"center", gap:5,
                    background: active ? bg : "#F5F6F8",
                    color: active ? color : C.muted,
                    border: active ? `1.5px solid ${color}` : "1.5px solid transparent",
                    borderRadius:20, padding:"5px 13px",
                    fontSize:12, fontWeight: active ? 700 : 500,
                    cursor:"pointer", transition:"all 0.15s",
                  }}>
                  <div style={{ width:7, height:7, borderRadius:"50%", background: active ? color : C.muted, flexShrink:0, transition:"background 0.15s" }} />
                  {shortLabel}
                </button>
              );
            })}
            {/* 전체 선택/해제 */}
            <button
              onClick={() => setSelectedTypes(
                selectedTypes.length === HOUSE_TYPES.length
                  ? ["apt"]
                  : HOUSE_TYPES.map(t => t.key)
              )}
              style={{ flexShrink:0, background:"none", border:"none", color:C.muted, fontSize:12, fontWeight:500, cursor:"pointer", padding:"5px 4px", textDecoration:"underline", textUnderlineOffset:2 }}>
              {selectedTypes.length === HOUSE_TYPES.length ? "전체해제" : "전체선택"}
            </button>
          </div>
        </div>
      )}

      {/* 일정 탭 헤더 */}
      {activeTab==="calendar" && (
        <div style={{ background:"#fff", padding:"52px 20px 14px", flexShrink:0, boxShadow:"0 1px 8px rgba(0,0,0,0.05)", zIndex:50 }}>
          <div style={{ display:"flex", alignItems:"center", gap:8 }}>
            <Icon.Calendar size={22} color={C.blue} filled/>
            <h1 style={{ fontSize:22, fontWeight:900, color:C.text, margin:0, letterSpacing:"-0.8px" }}>청약 일정</h1>
          </div>
          <p style={{ fontSize:12, color:C.muted, margin:"4px 0 0" }}>달력에서 청약 일정을 확인하세요</p>
        </div>
      )}

      {/* 콘텐츠 */}
      {activeTab==="list" && (
        <div ref={scrollRef} onTouchStart={onTouchStart} onTouchMove={onTouchMove} onTouchEnd={onTouchEnd}
          style={{ flex:1, overflowY:"auto", overscrollBehavior:"none" }}>
          {/* pull-to-refresh */}
          <div style={{ height:isRefreshing?56:Math.max(pullY*0.82,0), transition:isPulling?"none":"height 0.3s ease", display:"flex", alignItems:"center", justifyContent:"center", background:C.bg, overflow:"hidden" }}>
            {(pullY>6||isRefreshing)&&(
              <div style={{ display:"flex", flexDirection:"column", alignItems:"center", gap:5, opacity:Math.min(pullProgress*2.2,1) }}>
                <div style={{ animation:isRefreshing?"spin 0.7s linear infinite":"none", transform:isRefreshing?"none":`rotate(${pullProgress*270}deg)`, transition:isRefreshing?"none":"transform 0.04s linear" }}>
                  <Icon.Refresh size={22} color={pullReady||isRefreshing?C.blue:"#C0C8E8"}/>
                </div>
                <span style={{ fontSize:11, fontWeight:700, color:pullReady||isRefreshing?C.blue:C.muted }}>
                  {isRefreshing?"새로고침 중...":pullReady?"놓아서 새로고침":"당겨서 새로고침"}
                </span>
              </div>
            )}
          </div>
          <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", padding:"14px 20px 6px" }}>
            <span style={{ fontSize:14, color:"#666", fontWeight:600 }}>총 <span style={{ color:C.blue, fontWeight:800 }}>{filtered.length}</span>개</span>
            <select value={sortBy} onChange={e=>setSortBy(e.target.value)}
              style={{ background:"#fff", border:"1px solid #E8E8E8", borderRadius:10, padding:"6px 10px", fontSize:13, color:"#444", fontWeight:600, outline:"none", cursor:"pointer" }}>
              {SORT_OPTIONS.map(o=><option key={o.value} value={o.value}>{o.label}</option>)}
            </select>
          </div>
          <div style={{ padding:"4px 16px 100px" }}>
            {loading
              ? <div style={{ textAlign:"center", padding:"60px 0", color:C.muted, fontSize:15 }}>불러오는 중...</div>
              : filtered.length===0
              ? <div style={{ textAlign:"center", padding:"60px 0", color:C.muted, fontSize:15 }}>조건에 맞는 청약 공고가 없습니다</div>
              : filtered.map(item=><AptCard key={item.id||item.houseNm} item={item} onClick={setSelectedItem} bookmarks={bookmarks} onToggleBookmark={toggleBookmark} />)
            }
          </div>
        </div>
      )}

      {activeTab==="calendar" && <CalendarTab items={items} onSelectItem={setSelectedItem} />}
      {activeTab==="bookmark" && <BookmarkTab items={items} bookmarks={bookmarks} onToggleBookmark={toggleBookmark} onSelectItem={setSelectedItem} />}
      {activeTab==="mypage" && <MyPageTab bookmarks={bookmarks} items={items} />}

      {/* API 배너 */}
      {usingMock&&activeTab==="list"&&(
        <div style={{ position:"fixed", bottom:72, left:"50%", transform:"translateX(-50%)", background:"#222", color:"#fff", borderRadius:14, padding:"10px 18px", fontSize:12, fontWeight:600, width:"calc(100% - 32px)", maxWidth:398, textAlign:"center", zIndex:40, boxShadow:"0 4px 20px rgba(0,0,0,0.2)" }}>
          data.go.kr에서 API 키 발급 후 <code style={{ background:"#444", padding:"1px 6px", borderRadius:4 }}>API_KEY</code> 변수에 입력하세요
        </div>
      )}

      {/* 하단 탭바 */}
      <div style={{ position:"fixed", bottom:0, left:"50%", transform:"translateX(-50%)", width:"100%", maxWidth:430, background:"#fff", borderTop:"1px solid #F0F0F0", display:"flex", padding:"10px 0 20px", zIndex:50 }}>
        {TABS.map(tab=>(
          <button key={tab.key} onClick={()=>setActiveTab(tab.key)}
            style={{ flex:1, background:"none", border:"none", cursor:"pointer", display:"flex", flexDirection:"column", alignItems:"center", gap:4, position:"relative", padding:0 }}>
            {tab.icon(activeTab===tab.key)}
            <span style={{ fontSize:10, fontWeight:700, color:activeTab===tab.key?C.blue:C.muted, letterSpacing:"-0.2px" }}>{tab.label}</span>
            {tab.badge>0 && (
              <span style={{ position:"absolute", top:0, right:"50%", transform:"translateX(14px)", background:C.orange, color:"#fff", fontSize:9, fontWeight:800, width:16, height:16, borderRadius:"50%", display:"flex", alignItems:"center", justifyContent:"center" }}>{tab.badge}</span>
            )}
          </button>
        ))}
      </div>

      {showSidoSheet&&<SidoBottomSheet selected={selectedSido} onSelect={setSelectedSido} onClose={()=>setShowSidoSheet(false)} />}
      {selectedItem&&<DetailModal item={selectedItem} onClose={()=>setSelectedItem(null)} />}
    </div>
  );
}
