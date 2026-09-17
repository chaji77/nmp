function isValidEmail(email) {
  var emailPattern = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
  return emailPattern.test(email);
}
function isValidDate(dateString) {
  let formattedDateString;
  if (/^\d{4}-\d{2}-\d{2}$/.test(dateString)) {
    formattedDateString = dateString;
  } else if (/^\d{8}$/.test(dateString)) {
    formattedDateString = dateString.slice(0, 4) + "-" + dateString.slice(4, 6) + "-" + dateString.slice(6, 8);
  } else {
    return false;
  }
  var date = new Date(formattedDateString);
  var timestamp = date.getTime();

  if (typeof timestamp !== 'number' || Number.isNaN(timestamp)) {
    return false; // 유효하지 않은 날짜면 false 반환
  }
  return formattedDateString === date.toISOString().substring(0, 10);
}
function isValidPhoneNumber(phoneNumber) {
  const regex = /^(02|0\d{1,2})-?\d{3,4}-?\d{4}|01[016789]-?\d{3,4}-?\d{4}|080-?\d{4}-?\d{4}|15[0-9]{2}-?\d{4}$/;
  return regex.test(phoneNumber);
}
function isValidResidentRegistrationNumber(number) {
  const digits = number.split('').map(num => parseInt(num, 10));
  const checkSum = (2*digits[0] + 3*digits[1] + 4*digits[2] + 5*digits[3] + 6*digits[4] + 7*digits[5] + 8*digits[6] + 9*digits[7] + 2*digits[8] + 3*digits[9] + 4*digits[10] + 5*digits[11]) % 11;
  return (11 - checkSum) % 10 === digits[12];
}
function isValidBusinessNumber(businessNumber) {
  businessNumber = businessNumber.replace(/-/g, '');
  if (businessNumber.length !== 10 || isNaN(businessNumber)) {
    return false;
  }
  const weights = [1, 3, 7, 1, 3, 7, 1, 3, 5];
  let sum = 0;
  for (let i = 0; i < 9; i++) {
    sum += parseInt(businessNumber[i], 10) * weights[i];
  }
  sum += Math.floor((parseInt(businessNumber[8], 10) * 5) / 10);
  const checkDigit = (10 - (sum % 10)) % 10;
  return checkDigit === parseInt(businessNumber[9], 10);
}

function checkNumber(event) {
  const key = event.key;
  if (/[^0-9]/.test(key) && !['Backspace', 'ArrowLeft', 'ArrowRight', 'Delete'].includes(event.key)) {
    event.preventDefault();
  }
}